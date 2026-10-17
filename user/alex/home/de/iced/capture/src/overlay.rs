use std::cell::Cell;
use std::collections::HashMap;

use iced::{
    Color, Element, Length, Subscription, Task, Theme,
    futures::{SinkExt, Stream},
    keyboard,
    time::Duration,
    widget::{Canvas, container, space},
    window,
};
use iced_layershell::{
    build_pattern::daemon,
    reexport::{Anchor, IcedId, KeyboardInteractivity, Layer, NewLayerShellSettings, OutputOption},
    settings::{LayerShellSettings, Settings, StartMode},
    to_layer_message,
};

use widget::{font, palette as p};

use crate::{
    Mode,
    canvas::Overlay,
    geometry::{Point, Rect},
    instance::Guard,
    memory::{self, Saved},
    output::Output,
    screenshot,
    selection::Selection,
    tool,
    video::Recording,
};

const NAMESPACE: &str = env!("CARGO_PKG_NAME");

const HIDE_MS: u64 = 100;
const RECORDER_POLL_MS: u64 = 250;
const INDICATOR_THICKNESS: i32 = 2;

pub struct State {
    mode: Mode,
    outputs: Vec<Output>,
    surface: HashMap<IcedId, String>,
    selection: Selection,
    recording: Option<Recording>,
    guard: Option<Guard>,
}

#[to_layer_message(multi)]
#[derive(Debug, Clone)]
pub enum Message {
    Press(String, Point),
    Drag(String, Point),
    Release,
    Confirm,
    Cancel,
    Captured(Result<(), String>),
    Record(Rect),
    Stop,
    Poll,
}

fn layer(output: &str) -> NewLayerShellSettings {
    NewLayerShellSettings {
        size: None,
        layer: Layer::Overlay,
        anchor: Anchor::Top | Anchor::Bottom | Anchor::Left | Anchor::Right,
        exclusive_zone: Some(-1),
        margin: Some((0, 0, 0, 0)),
        keyboard_interactivity: KeyboardInteractivity::Exclusive,
        output_option: OutputOption::OutputName(output.to_owned()),
        events_transparent: false,
        namespace: Some(NAMESPACE.to_owned()),
    }
}

fn boot(
    mode: Mode,
    outputs: Vec<Output>,
    saved: Option<Saved>,
    guard: Option<Guard>,
) -> (State, Task<Message>) {
    let mut surface = HashMap::new();
    let open: Vec<_> = outputs
        .iter()
        .map(|output| {
            let (id, task) = Message::layershell_open(layer(&output.name));
            surface.insert(id, output.name.clone());
            task
        })
        .collect();
    let state = State {
        mode,
        outputs,
        surface,
        selection: Selection::new(saved),
        recording: None,
        guard,
    };
    (state, Task::batch(open))
}

fn indicator_layer(output: &str, strip: Rect) -> NewLayerShellSettings {
    NewLayerShellSettings {
        size: Some((strip.width as u32, strip.height as u32)),
        layer: Layer::Overlay,
        anchor: Anchor::Top | Anchor::Left,
        exclusive_zone: Some(-1),
        margin: Some((strip.y, 0, 0, strip.x)),
        keyboard_interactivity: KeyboardInteractivity::None,
        output_option: OutputOption::OutputName(output.to_owned()),
        events_transparent: true,
        namespace: Some(NAMESPACE.to_owned()),
    }
}

fn indicate(state: &State) -> Task<Message> {
    let Some(saved) = &state.selection.current else {
        return Task::none();
    };
    let Some(output) = state
        .outputs
        .iter()
        .find(|output| output.name == saved.output)
    else {
        return Task::none();
    };
    let Some(recorded) = saved.rect.even() else {
        return Task::none();
    };
    Task::batch(
        recorded
            .frame(INDICATOR_THICKNESS, output.rect.width, output.rect.height)
            .into_iter()
            .map(|strip| Message::layershell_open(indicator_layer(&saved.output, strip)).1),
    )
}

fn global(state: &State, saved: &Saved) -> Option<Rect> {
    let output = state
        .outputs
        .iter()
        .find(|output| output.name == saved.output)?;
    Some(saved.rect.offset(output.rect.x, output.rect.y))
}

fn hide(state: &mut State) -> Task<Message> {
    Task::batch(
        state
            .surface
            .drain()
            .map(|(id, _)| Task::done(Message::RemoveWindow(id))),
    )
}

fn confirm(state: &mut State) -> Task<Message> {
    let Some(saved) = state.selection.current.clone() else {
        return Task::none();
    };
    let Some(rect) = global(state, &saved) else {
        return Task::none();
    };
    if let Err(error) = memory::store(&memory::path(state.mode), &saved) {
        eprintln!("capture: memory: {error}");
    }
    let hidden = Duration::from_millis(HIDE_MS);
    let capture = match state.mode {
        Mode::Screenshot => Task::perform(
            async move {
                tokio::time::sleep(hidden).await;
                screenshot::copy(rect)
            },
            Message::Captured,
        ),
        Mode::Video => Task::perform(tokio::time::sleep(hidden), move |()| Message::Record(rect)),
    };
    hide(state).chain(capture)
}

fn finish(state: &mut State, outcome: Result<(), String>) -> ! {
    drop(state.recording.take());
    drop(state.guard.take());
    match outcome {
        Ok(()) => std::process::exit(0),
        Err(error) => tool::fail(&format!("capture: {error}")),
    }
}

fn update(state: &mut State, message: Message) -> Task<Message> {
    match message {
        Message::Press(output, point) => state.selection.press(&output, point),
        Message::Drag(output, point) => state.selection.drag_to(&output, point),
        Message::Release => state.selection.release(),
        Message::Confirm if state.surface.is_empty() => {}
        Message::Confirm => return confirm(state),
        Message::Cancel => finish(state, Ok(())),
        Message::Captured(outcome) => finish(state, outcome),
        Message::Record(rect) => match Recording::start(rect) {
            Ok(recording) => {
                state.recording = Some(recording);
                return indicate(state);
            }
            Err(error) => finish(state, Err(error)),
        },
        Message::Stop => {
            let outcome = state.recording.take().map_or(Ok(()), Recording::stop);
            finish(state, outcome)
        }
        Message::Poll => {
            if state
                .recording
                .as_mut()
                .is_some_and(|recording| !recording.running())
            {
                finish(state, Err("recorder stopped".to_owned()))
            }
        }
        _ => {}
    }
    Task::none()
}

fn view(state: &State, id: window::Id) -> Element<'_, Message> {
    let Some(output) = state.surface.get(&id) else {
        return container(space())
            .width(Length::Fill)
            .height(Length::Fill)
            .style(|_| container::Style {
                background: Some(p::base08().into()),
                ..Default::default()
            })
            .into();
    };
    Canvas::new(Overlay {
        output,
        rect: state.selection.on(output),
    })
    .width(Length::Fill)
    .height(Length::Fill)
    .into()
}

fn interrupt() -> impl Stream<Item = Message> {
    iced::stream::channel(1, async |mut sender| {
        let Ok(mut signal) =
            tokio::signal::unix::signal(tokio::signal::unix::SignalKind::interrupt())
        else {
            return;
        };
        while signal.recv().await.is_some() {
            let _ = sender.send(Message::Stop).await;
        }
    })
}

fn subscription(state: &State) -> Subscription<Message> {
    let key = keyboard::listen().filter_map(|event| {
        let keyboard::Event::KeyPressed { key, .. } = event else {
            return None;
        };
        match key {
            keyboard::Key::Named(keyboard::key::Named::Enter) => Some(Message::Confirm),
            keyboard::Key::Named(keyboard::key::Named::Escape) => Some(Message::Cancel),
            _ => None,
        }
    });
    let stop = Subscription::run(interrupt);
    match state.recording {
        Some(_) => Subscription::batch([
            key,
            stop,
            iced::time::every(Duration::from_millis(RECORDER_POLL_MS)).map(|_| Message::Poll),
        ]),
        None => Subscription::batch([key, stop]),
    }
}

fn style(_state: &State, _theme: &Theme) -> iced::theme::Style {
    iced::theme::Style {
        background_color: Color::TRANSPARENT,
        text_color: p::base05(),
    }
}

pub fn run(
    mode: Mode,
    outputs: Vec<Output>,
    saved: Option<Saved>,
    guard: Option<Guard>,
) -> Result<(), iced_layershell::Error> {
    let guard = Cell::new(guard);
    daemon(
        move || boot(mode, outputs.clone(), saved.clone(), guard.take()),
        NAMESPACE,
        update,
        view,
    )
    .style(style)
    .subscription(subscription)
    .settings(Settings {
        default_font: font::DEFAULT,
        layer_settings: LayerShellSettings {
            start_mode: StartMode::Background,
            ..Default::default()
        },
        ..Default::default()
    })
    .run()
}
