mod action;
mod card;
mod prompt;

use iced::{Color, Size, Subscription, Task, Theme, keyboard, window};
use iced_layershell::{
    application,
    reexport::{Anchor, KeyboardInteractivity, Layer},
    settings::{LayerShellSettings, Settings},
    to_layer_message,
};

use widget::{font, palette as p};

#[derive(Debug, Clone, Copy, PartialEq, Default)]
pub enum Choice {
    No,
    #[default]
    Yes,
}

pub struct State {
    pub selected: Choice,
    pub size: Size,
}

impl Default for State {
    fn default() -> Self {
        Self {
            selected: Choice::default(),
            size: Size::new(1920.0, 1080.0),
        }
    }
}

#[to_layer_message]
#[derive(Debug, Clone)]
pub enum Message {
    Choose(Choice),
    Key(keyboard::key::Named),
    Resized(Size),
}

fn finish(choice: Choice) -> ! {
    let (code, label) = match choice {
        Choice::Yes => (0, "yes"),
        Choice::No => (1, "no"),
    };
    println!("{label}");
    std::process::exit(code);
}

fn namespace() -> String {
    String::from("media-boot-prompt")
}

fn update(state: &mut State, message: Message) -> Task<Message> {
    match message {
        Message::Choose(choice) => finish(choice),
        Message::Resized(size) => {
            state.size = size;
            Task::none()
        }
        Message::Key(named) => {
            match named {
                keyboard::key::Named::ArrowLeft => state.selected = Choice::No,
                keyboard::key::Named::ArrowRight => state.selected = Choice::Yes,
                keyboard::key::Named::Enter => finish(state.selected),
                keyboard::key::Named::Escape | keyboard::key::Named::Backspace => {
                    finish(Choice::No)
                }
                _ => {}
            }
            Task::none()
        }
        _ => Task::none(),
    }
}

fn subscription(_state: &State) -> Subscription<Message> {
    Subscription::batch([
        keyboard::listen().filter_map(|event| match event {
            keyboard::Event::KeyPressed {
                key: keyboard::Key::Named(named),
                ..
            } => Some(Message::Key(named)),
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
    application(State::default, namespace, update, card::view)
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
