mod action;
mod screen;
mod tray;

use std::collections::HashMap;

use iced::window::Id;
use iced::{Color, Task, Theme};
use iced_layershell::{
    build_pattern::daemon,
    settings::{LayerShellSettings, Settings, StartMode},
    to_layer_message,
};

use widget::{font, palette as p};

pub const NAMESPACE: &str = env!("CARGO_PKG_NAME");

#[derive(Default)]
pub struct State {
    side: HashMap<Id, f32>,
}

#[to_layer_message(multi)]
#[derive(Debug, Clone)]
pub enum Message {
    Open,
}

fn boot(screen: &[screen::Screen]) -> (State, Task<Message>) {
    let mut side = HashMap::new();
    let mut task = Vec::new();
    for s in screen {
        let (id, open) = Message::layershell_open(s.surface());
        side.insert(id, s.side());
        task.push(open);
    }
    (State { side }, Task::batch(task))
}

fn update(_state: &mut State, message: Message) -> Task<Message> {
    if let Message::Open = message {
        action::open();
    }
    Task::none()
}

fn view(state: &State, id: Id) -> iced::Element<'_, Message> {
    match state.side.get(&id) {
        Some(&side) => tray::view(side),
        None => iced::widget::Space::new().into(),
    }
}

fn style(_state: &State, _theme: &Theme) -> iced::theme::Style {
    iced::theme::Style {
        background_color: Color::TRANSPARENT,
        text_color: p::base05(),
    }
}

fn main() -> hmerr::Result<()> {
    let screen = screen::parse()?;

    daemon(move || boot(&screen), NAMESPACE, update, view)
        .style(style)
        .settings(Settings {
            default_font: font::DEFAULT,
            layer_settings: LayerShellSettings {
                start_mode: StartMode::Background,
                ..Default::default()
            },
            ..Default::default()
        })
        .run()?;

    Ok(())
}
