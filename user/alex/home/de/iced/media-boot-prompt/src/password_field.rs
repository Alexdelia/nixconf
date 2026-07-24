use iced::{
    Background, Border, Element, Theme,
    widget::{text_input, text_input::Status},
};

use widget::{
    font, palette as p,
    unit::{vh, vw},
};

use crate::{FIELD_ID, Message, State};

pub fn password_field(state: &State) -> Element<'_, Message> {
    let radius = vh(state.size, 2.0);

    text_input("", &state.password)
        .id(FIELD_ID)
        .secure(true)
        .on_input(Message::Input)
        .on_submit_maybe(if state.password.is_empty() {
            None
        } else {
            Some(Message::Submit)
        })
        .font(font::DEFAULT)
        .size(vh(state.size, 8.0))
        .padding(vh(state.size, 4.0))
        .width(vw(state.size, 40.0))
        .style(move |_theme: &Theme, status| {
            let border = match status {
                Status::Focused { .. } => p::base0e(),
                _ => p::base03(),
            };
            text_input::Style {
                background: Background::Color(p::base00()),
                border: Border {
                    radius: radius.into(),
                    width: vh(state.size, 1.0),
                    color: border,
                },
                icon: p::base05(),
                placeholder: p::base04(),
                value: p::base05(),
                selection: p::base03(),
            }
        })
        .into()
}
