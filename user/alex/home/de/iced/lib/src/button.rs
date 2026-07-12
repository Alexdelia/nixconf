use iced::{
    Background, Border,
    widget::button::{Button, Status, Style},
};

use crate::{font, palette as p};

const PADDING_RATIO: f32 = 0.3;
const RADIUS_RATIO: f32 = 0.3;

fn bare<'a, Message: Clone + 'a>(label: &'a str, size: f32) -> Button<'a, Message> {
    iced::widget::button(iced::widget::text(label).size(size).font(font::NUMERIC))
        .padding(size * PADDING_RATIO)
}

pub fn icon<'a, Message: Clone + 'a>(
    label: &'a str,
    size: f32,
    selected: bool,
) -> Button<'a, Message> {
    bare(label, size).style(move |_theme, status| {
        let background = match status {
            Status::Hovered => p::base02(),
            Status::Pressed => p::base03(),
            _ => p::base01(),
        };
        Style {
            background: Some(Background::Color(background)),
            text_color: if selected { p::base0e() } else { p::base05() },
            border: Border {
                radius: (size * RADIUS_RATIO).into(),
                ..Default::default()
            },
            ..Default::default()
        }
    })
}

pub fn text<'a, Message: Clone + 'a>(
    label: &'a str,
    size: f32,
    selected: bool,
) -> Button<'a, Message> {
    bare(label, size).style(move |_theme, status| {
        let hovered = matches!(status, Status::Hovered | Status::Pressed);
        let background = if selected {
            if hovered { p::base0c() } else { p::base0d() }
        } else if hovered {
            p::base03()
        } else {
            p::base02()
        };
        Style {
            background: Some(Background::Color(background)),
            text_color: if selected { p::base00() } else { p::base05() },
            border: Border {
                radius: (size * RADIUS_RATIO).into(),
                ..Default::default()
            },
            ..Default::default()
        }
    })
}
