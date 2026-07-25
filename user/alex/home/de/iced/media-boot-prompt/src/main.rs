mod action;
mod card;
mod password_field;
mod prompt;

use std::io::Write;

use iced::{Color, Size, Subscription, Task, Theme, keyboard, window};
use iced_layershell::{
    application,
    reexport::{Anchor, KeyboardInteractivity, Layer},
    settings::{LayerShellSettings, Settings},
    to_layer_message,
};

use widget::{font, palette as p};

pub const FIELD_ID: &str = "password";

pub struct State {
    pub password: String,
    pub size: Size,
}

impl Default for State {
    fn default() -> Self {
        Self {
            password: String::new(),
            size: Size::new(1920.0, 1080.0),
        }
    }
}

#[to_layer_message]
#[derive(Debug, Clone)]
pub enum Message {
    Input(String),
    Submit,
    Cancel,
    Resized(Size),
}

fn submit(password: &str) -> ! {
    print!("{password}");
    let _ = std::io::stdout().flush();
    std::process::exit(0);
}

fn cancel() -> ! {
    std::process::exit(1);
}

fn boot() -> (State, Task<Message>) {
    (State::default(), iced::widget::operation::focus(FIELD_ID))
}

fn update(state: &mut State, message: Message) -> Task<Message> {
    match message {
        Message::Input(password) => {
            state.password = password;
            Task::none()
        }
        Message::Submit => submit(&state.password),
        Message::Cancel => cancel(),
        Message::Resized(size) => {
            state.size = size;
            Task::none()
        }
        _ => Task::none(),
    }
}

fn subscription(_state: &State) -> Subscription<Message> {
    Subscription::batch([
        keyboard::listen().filter_map(|event| match event {
            keyboard::Event::KeyPressed {
                key: keyboard::Key::Named(keyboard::key::Named::Escape),
                ..
            } => Some(Message::Cancel),
            _ => None,
        }),
        window::resize_events().map(|(_id, size)| Message::Resized(size)),
    ])
}

fn style(_state: &State, _theme: &Theme) -> iced::theme::Style {
    iced::theme::Style {
        background_color: Color::TRANSPARENT,
        text_color: p::base05(),
    }
}

fn main() -> Result<(), iced_layershell::Error> {
    application(boot, env!("CARGO_PKG_NAME"), update, card::view)
        .style(style)
        .subscription(subscription)
        .settings(Settings {
            default_font: font::DEFAULT,
            layer_settings: LayerShellSettings {
                anchor: Anchor::Top | Anchor::Bottom | Anchor::Left | Anchor::Right,
                layer: Layer::Overlay,
                exclusive_zone: 0,
                keyboard_interactivity: KeyboardInteractivity::Exclusive,
                ..Default::default()
            },
            ..Default::default()
        })
        .run()
}
