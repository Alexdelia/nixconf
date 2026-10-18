use std::cell::Cell;
use std::collections::{HashMap, HashSet};

use iced::{
    Color, Element, Length, Subscription, Task, Theme,
    futures::{SinkExt, Stream},
    keyboard,
    widget::{Canvas, space},
    window,
};
use iced_layershell::{
    actions::ActionCallback,
    build_pattern::daemon,
    reexport::{Anchor, IcedId, KeyboardInteractivity, Layer, NewLayerShellSettings, OutputOption},
    settings::{LayerShellSettings, Settings, StartMode},
    to_layer_message,
};

use widget::{font, palette as p};

use crate::{
    Mode,
    canvas::{Look, Overlay},
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

pub struct State {
    mode: Mode,
    output: Vec<Output>,
    surface: HashMap<IcedId, String>,
    frame: Option<IcedId>,
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
    output: Vec<Output>,
    saved: Option<Saved>,
    guard: Option<Guard>,
) -> (State, Task<Message>) {
    let mut surface = HashMap::new();
    let open: Vec<_> = output
        .iter()
        .map(|monitor| {
            let (id, task) = Message::layershell_open(layer(&monitor.name));
            surface.insert(id, monitor.name.clone());
            task
        })
        .collect();
    let state = State {
        mode,
        output,
        surface,
        frame: None,
        hiding: HashSet::new(),
        queued: None,
        selection: Selection::new(saved),
        recording: None,
        guard,
    };
    (state, Task::batch(open))
}

fn global(state: &State, saved: &Saved) -> Option<Rect> {
    let output = state
        .output
        .iter()
        .find(|candidate| candidate.name == saved.output)?;
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
    queue(state, rect)
}

fn keep_as_frame(state: &mut State) -> Task<Message> {
    let Some(saved) = &state.selection.current else {
        return Task::none();
    };
    let Some(id) = state
        .surface
        .iter()
        .find(|(_, output)| **output == saved.output)
        .map(|(&id, _)| id)
    else {
        return Task::none();
    };
    state.surface.remove(&id);
    state.frame = Some(id);
    Task::batch([
        Task::done(Message::KeyboardInteractivityChange {
            id,
            keyboard_interactivity: KeyboardInteractivity::None,
        }),
        Task::done(Message::SetInputRegion {
            id,
            callback: ActionCallback::new(|_| {}),
        }),
    ])
}

fn queue(state: &mut State, rect: Rect) -> Task<Message> {
    state.queued = Some(rect);
    let frame = match state.mode {
        Mode::Video => keep_as_frame(state),
        Mode::Screenshot => Task::none(),
    };
    Task::batch([frame, hide(state), flush(state)])
}

fn flush(state: &mut State) -> Task<Message> {
    match state.queued {
        Some(rect) if state.hiding.is_empty() => {
            state.queued = None;
            capture(state.mode, rect)
        }
        _ => Task::none(),
    }
}

fn capture(mode: Mode, rect: Rect) -> Task<Message> {
    match mode {
        Mode::Screenshot => Task::perform(screenshot::copy(rect), Message::Captured),
        Mode::Video => Task::done(Message::Record(rect)),
    }
}

fn vanished(state: &mut State, output: &str) -> Task<Message> {
    state.output.retain(|candidate| candidate.name != output);
    state.selection.forget(output);
    match state.surface.is_empty() {
        true => Task::done(Message::Cancel),
        false => Task::none(),
    }
}

fn closed(state: &mut State, id: IcedId) -> Task<Message> {
    if state.frame == Some(id) {
        state.frame = None;
    }
    if let Some(output) = state.surface.remove(&id) {
        return vanished(state, &output);
    }
    state.hiding.remove(&id);
    flush(state)
}

fn switch(state: &mut State, mode: Mode) {
    state.mode = mode;
    state.selection = Selection::new(memory::load(&memory::path(mode), &state.output));
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
                return Task::perform(exit, Message::Exited);
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
    Frame,
    Blank,
}

fn appearance(
    surface: &HashMap<IcedId, String>,
    frame: Option<IcedId>,
    id: IcedId,
) -> Appearance<'_> {
    match surface.get(&id) {
        Some(output) => Appearance::Selection(output),
        None if frame == Some(id) => Appearance::Frame,
        None => Appearance::Blank,
    }
}

fn canvas(overlay: Overlay<'_>) -> Element<'_, Message> {
    Canvas::new(overlay)
        .width(Length::Fill)
        .height(Length::Fill)
        .into()
}

fn view(state: &State, id: window::Id) -> Element<'_, Message> {
    match (
        appearance(&state.surface, state.frame, id),
        &state.selection.current,
    ) {
        (Appearance::Selection(output), _) => canvas(Overlay {
            output,
            rect: state.selection.on(output),
            look: match state.mode {
                Mode::Screenshot => Look::Screenshot,
                Mode::Video => Look::Video,
            },
        }),
        (Appearance::Frame, Some(saved)) => canvas(Overlay {
            output: &saved.output,
            rect: Some(saved.rect),
            look: Look::Recording,
        }),
        (Appearance::Frame | Appearance::Blank, _) => space().into(),
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
    output: Vec<Output>,
    saved: Option<Saved>,
    guard: Guard,
) -> Result<(), iced_layershell::Error> {
    let guard = Cell::new(Some(guard));
    daemon(
        move || boot(mode, output.clone(), saved.clone(), guard.take()),
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

    fn selecting(mode: Mode, surface: &[(IcedId, &str)], selected: &str) -> State {
        State {
            mode,
            output: surface
                .iter()
                .zip([0, 1920])
                .map(|(&(_, name), x)| output(name, x))
                .collect(),
            surface: surface
                .iter()
                .map(|&(id, name)| (id, name.to_owned()))
                .collect(),
            frame: None,
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
        let mut state = selecting(
            Mode::Screenshot,
            &[(gone, "DP-1"), (kept, "HDMI-A-1")],
            "HDMI-A-1",
        );

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
        let mut state = selecting(
            Mode::Screenshot,
            &[(gone, "DP-1"), (kept, "HDMI-A-1")],
            "DP-1",
        );

        let _ = closed(&mut state, gone);
        assert_eq!(state.selection.current, None);
        assert!(state.output.iter().all(|output| output.name != "DP-1"));
        assert_eq!(state.surface.len(), 1);
    }

    #[test]
    fn removed_selection_surface_is_blank_not_red() {
        let surface = HashMap::new();
        assert_eq!(
            appearance(&surface, None, IcedId::unique()),
            Appearance::Blank
        );
    }

    #[test]
    fn appearance_by_kind() {
        let selection = IcedId::unique();
        let frame = IcedId::unique();
        let surface = HashMap::from([(selection, "DP-1".to_owned())]);
        assert_eq!(
            appearance(&surface, Some(frame), selection),
            Appearance::Selection("DP-1")
        );
        assert_eq!(appearance(&surface, Some(frame), frame), Appearance::Frame);
    }

    fn selected_rect(state: &State) -> Rect {
        let saved = state.selection.current.clone().unwrap();
        global(state, &saved).unwrap()
    }

    #[test]
    fn video_queue_keeps_selected_surface_as_frame() {
        let other = IcedId::unique();
        let selected = IcedId::unique();
        let mut state = selecting(
            Mode::Video,
            &[(other, "DP-1"), (selected, "HDMI-A-1")],
            "HDMI-A-1",
        );

        let rect = selected_rect(&state);
        let _ = queue(&mut state, rect);
        assert_eq!(state.frame, Some(selected));
        assert_eq!(state.hiding, HashSet::from([other]));
        assert!(state.surface.is_empty());
        assert!(state.queued.is_some());
    }

    #[test]
    fn video_queue_on_single_output_records_right_away() {
        let selected = IcedId::unique();
        let mut state = selecting(Mode::Video, &[(selected, "DP-1")], "DP-1");

        let rect = selected_rect(&state);
        let _ = queue(&mut state, rect);
        assert_eq!(state.frame, Some(selected));
        assert_eq!(state.queued, None);
    }

    #[test]
    fn screenshot_queue_hides_every_surface() {
        let other = IcedId::unique();
        let selected = IcedId::unique();
        let mut state = selecting(
            Mode::Screenshot,
            &[(other, "DP-1"), (selected, "HDMI-A-1")],
            "HDMI-A-1",
        );

        let rect = selected_rect(&state);
        let _ = queue(&mut state, rect);
        assert_eq!(state.frame, None);
        assert_eq!(state.hiding, HashSet::from([other, selected]));
        assert!(state.queued.is_some());
    }

    #[test]
    fn closed_frame_is_forgotten() {
        let selected = IcedId::unique();
        let mut state = selecting(Mode::Video, &[(selected, "DP-1")], "DP-1");
        let rect = selected_rect(&state);
        let _ = queue(&mut state, rect);

        let _ = closed(&mut state, selected);
        assert_eq!(state.frame, None);
    }
}
