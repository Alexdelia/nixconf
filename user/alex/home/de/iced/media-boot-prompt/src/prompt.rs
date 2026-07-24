use iced::{
    Center, Element,
    widget::{column, text},
};

use widget::{font, palette as p, unit::vh};

use crate::{Message, State, password_field::password_field};

pub fn view(state: &State) -> Element<'_, Message> {
    column![
        text("hello Maaike")
            .font(font::DEFAULT)
            .size(vh(state.size, 16.0))
            .color(p::base05()),
        text("do you wanna use the TV?")
            .font(font::DEFAULT)
            .size(vh(state.size, 8.0))
            .color(p::base04()),
        password_field(state),
    ]
    .spacing(vh(state.size, 7.0))
    .align_x(Center)
    .into()
}
