mod menu;

use std::io::Write;

use iced::{Color, Size, Subscription, Task, Theme, keyboard, window};
use iced_layershell::{
    application,
    reexport::{Anchor, KeyboardInteractivity, Layer},
    settings::{LayerShellSettings, Settings},
    to_layer_message,
};

use widget::{font, palette as p};

pub struct Entry {
    pub glyph: &'static str,
    pub command: &'static [&'static str],
}

pub const ENTRY: [Entry; 2] = [
    Entry {
        glyph: "",
        command: &["poweroff"],
    },
    Entry {
        glyph: "",
        command: &["reboot"],
    },
    /*
    Entry {
        glyph: "",
        command: &["systemctl", "hibernate"],
    },
    */
];

pub struct State {
    pub selected: usize,
    pub size: Size,
}

impl Default for State {
    fn default() -> Self {
        Self {
            selected: 0,
            size: Size::new(1920.0, 1080.0),
        }
    }
}

#[to_layer_message]
#[derive(Debug, Clone)]
pub enum Message {
    Move(isize),
    Activate(usize),
    ActivateSelected,
    Cancel,
    Resized(Size),
}

fn activate(entry: &Entry) -> ! {
    print!("{}", entry.command.join(" "));
    let _ = std::io::stdout().flush();
    std::process::exit(0);
}

fn cancel() -> ! {
    std::process::exit(1);
}

fn boot() -> (State, Task<Message>) {
    (State::default(), Task::none())
}

fn update(state: &mut State, message: Message) -> Task<Message> {
    match message {
        Message::Move(step) => {
            let count = ENTRY.len() as isize;
            state.selected = (state.selected as isize + step).rem_euclid(count) as usize;
            Task::none()
        }
        Message::Activate(index) => activate(&ENTRY[index]),
        Message::ActivateSelected => activate(&ENTRY[state.selected]),
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
        keyboard::listen().filter_map(|event| {
            let keyboard::Event::KeyPressed { key, .. } = event else {
                return None;
            };
            use keyboard::key::Named;
            match key {
                keyboard::Key::Named(Named::Escape) => Some(Message::Cancel),
                keyboard::Key::Named(Named::ArrowLeft | Named::ArrowUp) => Some(Message::Move(-1)),
                keyboard::Key::Named(Named::ArrowRight | Named::ArrowDown | Named::Tab) => {
                    Some(Message::Move(1))
                }
                keyboard::Key::Named(Named::Enter | Named::Space) => {
                    Some(Message::ActivateSelected)
                }
                keyboard::Key::Character(c) => match c.as_str() {
                    "h" | "k" => Some(Message::Move(-1)),
                    "l" | "j" => Some(Message::Move(1)),
                    _ => None,
                },
                _ => None,
            }
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
    application(boot, env!("CARGO_PKG_NAME"), update, menu::view)
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
