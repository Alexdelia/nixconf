use std::cell::Cell;
use std::collections::{HashMap, HashSet};

use iced::{
    Color, Element, Length, Subscription, Task, Theme,
    futures::{SinkExt, Stream},
    keyboard,
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
    instance::{self, Guard},
    memory::{self, Saved},
    output::Output,
    screenshot,
    selection::Selection,
    tool,
    video::{self, Phase, Recording},
};

const NAMESPACE: &str = env!("CARGO_PKG_NAME");

const INDICATOR_THICKNESS: i32 = 2;

pub struct State {
    mode: Mode,
    outputs: Vec<Output>,
    surface: HashMap<IcedId, String>,
    indicator: HashSet<IcedId>,
    hiding: HashSet<IcedId>,
    queued: Option<Rect>,
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
    Closed(IcedId),
    Captured(Result<(), String>),
    Record(Rect),
    Stop,
    Request(Mode),
    Exited(Result<(), String>),
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
        indicator: HashSet::new(),
        hiding: HashSet::new(),
        queued: None,
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

fn indicate(state: &mut State) -> Task<Message> {
    let Some(saved) = state.selection.current.clone() else {
        return Task::none();
    };
    let Some(output) = state
        .outputs
        .iter()
        .find(|output| output.name == saved.output)
    else {
        return Task::none();
    };
    let strips = saved
        .rect
        .frame(INDICATOR_THICKNESS, output.rect.width, output.rect.height);
    Task::batch(strips.into_iter().map(|strip| {
        let (id, task) = Message::layershell_open(indicator_layer(&saved.output, strip));
        state.indicator.insert(id);
        task
    }))
}

fn global(state: &State, saved: &Saved) -> Option<Rect> {
    let output = state
        .outputs
        .iter()
        .find(|output| output.name == saved.output)?;
    Some(saved.rect.offset(output.rect.x, output.rect.y))
}

fn hide(state: &mut State) -> Task<Message> {
    state.hiding.extend(state.surface.drain().map(|(id, _)| id));
    Task::batch(
        state
            .hiding
            .iter()
            .map(|&id| Task::done(Message::RemoveWindow(id))),
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
    state.queued = Some(rect);
    hide(state)
}

fn capture(mode: Mode, rect: Rect) -> Task<Message> {
    match mode {
        Mode::Screenshot => Task::perform(async move { screenshot::copy(rect) }, Message::Captured),
        Mode::Video => Task::done(Message::Record(rect)),
    }
}

fn vanished(state: &mut State, output: &str) -> Task<Message> {
    state.outputs.retain(|candidate| candidate.name != output);
    state.selection.forget(output);
    match state.surface.is_empty() {
        true => Task::done(Message::Cancel),
        false => Task::none(),
    }
}

fn closed(state: &mut State, id: IcedId) -> Task<Message> {
    state.indicator.remove(&id);
    if let Some(output) = state.surface.remove(&id) {
        return vanished(state, &output);
    }
    state.hiding.remove(&id);
    match state.queued {
        Some(rect) if state.hiding.is_empty() => {
            state.queued = None;
            capture(state.mode, rect)
        }
        _ => Task::none(),
    }
}

fn switch(state: &mut State, mode: Mode) {
    state.mode = mode;
    state.selection = Selection::new(memory::load(&memory::path(mode), &state.outputs));
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
        Message::Closed(id) => return closed(state, id),
        Message::Captured(outcome) => finish(state, outcome),
        Message::Record(rect) => match Recording::start(rect) {
            Ok((recording, exit)) => {
                state.recording = Some(recording);
                if let Some(Err(error)) = state.guard.as_ref().map(Guard::mark_recording) {
                    eprintln!("capture: lock file: {error}");
                }
                return Task::batch([indicate(state), Task::perform(exit, Message::Exited)]);
            }
            Err(error) => finish(state, Err(error)),
        },
        Message::Stop => match state.recording.as_mut() {
            Some(recording) => match recording.phase() {
                Phase::Running => recording.stop(),
                Phase::Stopping => {
                    recording.kill();
                    finish(state, Err("recorder killed".to_owned()))
                }
                Phase::Reaped => {}
            },
            None => finish(state, Ok(())),
        },
        Message::Request(_) if state.recording.is_some() => return update(state, Message::Stop),
        Message::Request(mode) if mode != state.mode && !state.surface.is_empty() => {
            switch(state, mode)
        }
        Message::Request(_) => {}
        Message::Exited(Ok(())) => match state
            .recording
            .as_mut()
            .filter(|recording| recording.phase() == Phase::Stopping)
        {
            Some(recording) => {
                recording.reaped();
                return Task::perform(
                    video::deliver(recording.file().to_owned()),
                    Message::Captured,
                );
            }
            None => finish(state, Err("recorder stopped".to_owned())),
        },
        Message::Exited(Err(error)) => finish(state, Err(error)),
        _ => {}
    }
    Task::none()
}

#[derive(Debug, PartialEq, Eq)]
enum Appearance<'a> {
    Selection(&'a str),
    Indicator,
    Blank,
}

fn appearance<'a>(
    surface: &'a HashMap<IcedId, String>,
    indicator: &HashSet<IcedId>,
    id: IcedId,
) -> Appearance<'a> {
    match surface.get(&id) {
        Some(output) => Appearance::Selection(output),
        None if indicator.contains(&id) => Appearance::Indicator,
        None => Appearance::Blank,
    }
}

fn view(state: &State, id: window::Id) -> Element<'_, Message> {
    match appearance(&state.surface, &state.indicator, id) {
        Appearance::Selection(output) => Canvas::new(Overlay {
            output,
            rect: state.selection.on(output),
            bracket: matches!(state.mode, Mode::Video),
        })
        .width(Length::Fill)
        .height(Length::Fill)
        .into(),
        Appearance::Indicator => container(space())
            .width(Length::Fill)
            .height(Length::Fill)
            .style(|_| container::Style {
                background: Some(p::base08().into()),
                ..Default::default()
            })
            .into(),
        Appearance::Blank => space().into(),
    }
}

const STOP_SIGNAL: [i32; 3] = [libc::SIGINT, libc::SIGTERM, libc::SIGHUP];

fn on_signal(raw: i32, message: Message) -> impl Stream<Item = Message> + use<> {
    let kind = tokio::signal::unix::SignalKind::from_raw(raw);
    iced::stream::channel(1, async move |mut sender| {
        let Ok(mut signal) = tokio::signal::unix::signal(kind) else {
            return;
        };
        while signal.recv().await.is_some() {
            let _ = sender.send(message.clone()).await;
        }
    })
}

fn stop_on(raw: &i32) -> impl Stream<Item = Message> + use<> {
    on_signal(*raw, Message::Stop)
}

fn request_on(mode: &Mode) -> impl Stream<Item = Message> + use<> {
    on_signal(instance::request_signal(*mode), Message::Request(*mode))
}

fn subscription(_state: &State) -> Subscription<Message> {
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
    let stop = Subscription::batch(STOP_SIGNAL.map(|raw| Subscription::run_with(raw, stop_on)));
    let request =
        Subscription::batch(Mode::ALL.map(|mode| Subscription::run_with(mode, request_on)));
    let closed = window::close_events().map(Message::Closed);
    Subscription::batch([key, stop, request, closed])
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
    guard: Guard,
) -> Result<(), iced_layershell::Error> {
    let guard = Cell::new(Some(guard));
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

#[cfg(test)]
mod test {
    use super::*;

    fn output(name: &str, x: i32) -> Output {
        Output {
            name: name.to_owned(),
            rect: Rect {
                x,
                y: 0,
                width: 1920,
                height: 1080,
            },
        }
    }

    fn selecting(surface: &[(IcedId, &str)], selected: &str) -> State {
        State {
            mode: Mode::Screenshot,
            outputs: surface
                .iter()
                .zip([0, 1920])
                .map(|(&(_, name), x)| output(name, x))
                .collect(),
            surface: surface
                .iter()
                .map(|&(id, name)| (id, name.to_owned()))
                .collect(),
            indicator: HashSet::new(),
            hiding: HashSet::new(),
            queued: None,
            selection: Selection::new(Some(Saved {
                output: selected.to_owned(),
                rect: Rect {
                    x: 10,
                    y: 10,
                    width: 100,
                    height: 100,
                },
            })),
            recording: None,
            guard: None,
        }
    }

    #[test]
    fn vanished_output_no_longer_blocks_capture() {
        let gone = IcedId::unique();
        let kept = IcedId::unique();
        let mut state = selecting(&[(gone, "DP-1"), (kept, "HDMI-A-1")], "HDMI-A-1");

        let _ = closed(&mut state, gone);
        state.queued = state
            .selection
            .current
            .clone()
            .and_then(|saved| global(&state, &saved));
        let _ = hide(&mut state);
        assert_eq!(state.hiding, HashSet::from([kept]));

        let _ = closed(&mut state, kept);
        assert_eq!(state.queued, None);
    }

    #[test]
    fn vanished_output_forgets_its_selection() {
        let gone = IcedId::unique();
        let kept = IcedId::unique();
        let mut state = selecting(&[(gone, "DP-1"), (kept, "HDMI-A-1")], "DP-1");

        let _ = closed(&mut state, gone);
        assert_eq!(state.selection.current, None);
        assert!(state.outputs.iter().all(|output| output.name != "DP-1"));
        assert_eq!(state.surface.len(), 1);
    }

    #[test]
    fn removed_selection_surface_is_blank_not_red() {
        let surface = HashMap::new();
        let indicator = HashSet::new();
        assert_eq!(
            appearance(&surface, &indicator, IcedId::unique()),
            Appearance::Blank
        );
    }

    #[test]
    fn appearance_by_kind() {
        let selection = IcedId::unique();
        let strip = IcedId::unique();
        let surface = HashMap::from([(selection, "DP-1".to_owned())]);
        let indicator = HashSet::from([strip]);
        assert_eq!(
            appearance(&surface, &indicator, selection),
            Appearance::Selection("DP-1")
        );
        assert_eq!(
            appearance(&surface, &indicator, strip),
            Appearance::Indicator
        );
    }
}
