mod audio;
mod osd;

use iced::{
    Color, Element, Size, Subscription, Task, Theme,
    futures::{Stream, StreamExt},
    time::{Duration, Instant},
    window::{self, Id},
};
use iced_layershell::{
    build_pattern::daemon,
    reexport::{Anchor, IcedId, KeyboardInteractivity, Layer, NewLayerShellSettings, OutputOption},
    settings::{LayerShellSettings, Settings, StartMode},
    to_layer_message,
};

use widget::{animation::Fade, font, palette as p};

use crate::audio::Volume;

const NAMESPACE: &str = env!("CARGO_PKG_NAME");

const HOLD_MS: u64 = 1000;
const FADE_MS: u64 = 200;

pub struct State {
    volume: Volume,
    surface: Option<IcedId>,
    size: Size,
    visible: bool,
    fade: Fade,
    alpha: f32,
    hide_at: Instant,
}

impl State {
    fn new() -> Self {
        Self {
            volume: Volume::default(),
            surface: None,
            size: Size::new(1920.0, 1080.0),
            visible: false,
            fade: Fade::new(false, FADE_MS),
            alpha: 0.0,
            hide_at: Instant::now(),
        }
    }
}

#[to_layer_message(multi)]
#[derive(Debug, Clone)]
pub enum Message {
    Seed(Option<Volume>),
    Volume(Option<Volume>),
    SinkEvent,
    Tick(Instant),
    Resized(Size),
}

fn layer() -> NewLayerShellSettings {
    NewLayerShellSettings {
        size: None,
        layer: Layer::Overlay,
        anchor: Anchor::Top | Anchor::Bottom | Anchor::Left | Anchor::Right,
        exclusive_zone: Some(0),
        margin: Some((0, 0, 0, 0)),
        keyboard_interactivity: KeyboardInteractivity::None,
        output_option: OutputOption::default(),
        events_transparent: true,
        namespace: Some(NAMESPACE.to_string()),
    }
}

fn boot() -> (State, Task<Message>) {
    (State::new(), Task::perform(audio::query(), Message::Seed))
}

fn update(state: &mut State, message: Message) -> Task<Message> {
    match message {
        Message::Seed(Some(volume)) => {
            state.volume = volume;
            Task::none()
        }
        Message::SinkEvent => Task::perform(audio::query(), Message::Volume),
        Message::Resized(size) => {
            state.size = size;
            Task::none()
        }
        Message::Volume(Some(volume)) => {
            let changed = volume.changed(state.volume);
            state.volume = volume;
            if !changed && state.surface.is_none() {
                return Task::none();
            }
            let now = Instant::now();
            state.hide_at = now + Duration::from_millis(HOLD_MS);
            state.visible = true;
            state.fade.to(true, now);
            match state.surface {
                Some(_) => Task::none(),
                None => {
                    let (id, task) = Message::layershell_open(layer());
                    state.surface = Some(id);
                    task
                }
            }
        }
        Message::Tick(now) => {
            if state.surface.is_none() {
                return Task::none();
            }
            state.alpha = state.fade.progress(now);
            if state.visible && now >= state.hide_at {
                state.visible = false;
                state.fade.to(false, now);
            }
            if !state.visible
                && !state.fade.is_animating(now)
                && let Some(id) = state.surface.take()
            {
                state.alpha = 0.0;
                return Task::done(Message::RemoveWindow(id));
            }
            Task::none()
        }
        _ => Task::none(),
    }
}

fn view(state: &State, _id: Id) -> Element<'_, Message> {
    osd::view(state.volume, state.alpha, state.size)
}

fn sink_event() -> impl Stream<Item = Message> {
    audio::event().map(|()| Message::SinkEvent)
}

fn subscription(state: &State) -> Subscription<Message> {
    let event = Subscription::run(sink_event);
    match state.surface {
        Some(_) => Subscription::batch([
            event,
            iced::time::every(Duration::from_millis(16)).map(Message::Tick),
            window::resize_events().map(|(_id, size)| Message::Resized(size)),
        ]),
        None => event,
    }
}

fn style(_state: &State, _theme: &Theme) -> iced::theme::Style {
    iced::theme::Style {
        background_color: Color::TRANSPARENT,
        text_color: p::base05(),
    }
}

fn main() -> Result<(), iced_layershell::Error> {
    daemon(boot, NAMESPACE, update, view)
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
