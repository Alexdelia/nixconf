use iced::{
    Background, Border, Bottom, Center, Color, Element, Fill, Length, Padding, Size,
    widget::{container, progress_bar, row, text},
};
use widget::{font, palette as p, unit::vh};

use crate::{Message, audio::Volume};

const MAX: f32 = 1.5;

const MUTE: &str = " ";

const UNIT_VH: f32 = 3.0;
const PAD_VH: f32 = UNIT_VH / 2.0;
const CARD_VH: f32 = UNIT_VH + 2.0 * PAD_VH;
const VALUE_VH: f32 = 8.0;
const GAP_VH: f32 = PAD_VH / 2.0;
const CARD_W_VH: f32 = 40.0;
const LIFT_VH: f32 = 8.0;

const OPACITY: f32 = 0.5;

fn fade(color: Color, alpha: f32) -> Color {
    Color {
        a: color.a * alpha,
        ..color
    }
}

pub fn view(volume: Volume, alpha: f32, size: Size) -> Element<'static, Message> {
    let accent = if volume.muted {
        p::base08()
    } else {
        p::base0e()
    };
    let translucent = alpha * OPACITY;
    let unit = vh(size, UNIT_VH);

    let value = if volume.muted {
        text(MUTE)
            .font(font::SYMBOL)
            .color(fade(p::base08(), alpha))
    } else {
        text(((volume.level * 100.0).round() as i32).to_string())
            .font(font::NUMERIC)
            .color(fade(p::base05(), alpha))
    }
    .size(unit)
    .line_height(1.0)
    .width(Fill)
    .height(Fill)
    .center();

    let bar = progress_bar(0.0..=MAX, volume.level.min(MAX))
        .length(Fill)
        .girth(unit)
        .style(move |_| progress_bar::Style {
            background: Background::Color(fade(p::base02(), translucent)),
            bar: Background::Color(fade(accent, translucent)),
            border: Border::default().rounded(unit / 2.0),
        });

    let card = container(
        row![
            bar,
            container(value)
                .width(Length::Fixed(vh(size, VALUE_VH / 2.0)))
                .height(Fill),
        ]
        .width(Fill)
        .spacing(vh(size, GAP_VH))
        .align_y(Center),
    )
    .width(Length::Fixed(vh(size, CARD_W_VH)))
    .height(Length::Fixed(vh(size, CARD_VH)))
    .padding(vh(size, PAD_VH))
    .align_y(Center)
    .style(move |_| container::Style {
        background: Some(Background::Color(fade(p::base01(), translucent))),
        border: Border::default().rounded(vh(size, CARD_VH / 2.0)),
        ..container::Style::default()
    });

    container(card)
        .width(Fill)
        .height(Fill)
        .align_x(Center)
        .align_y(Bottom)
        .padding(Padding::default().bottom(vh(size, LIFT_VH)))
        .into()
}
