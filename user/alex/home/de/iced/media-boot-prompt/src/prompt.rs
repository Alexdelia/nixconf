use iced::{
    Center, Element,
    widget::{column, text},
};

use widget::{font, palette as p, unit::vh};

use crate::{Message, State};

pub fn view(state: &State) -> Element<'static, Message> {
    column![
        text("hello Maaike")
            .font(font::DEFAULT)
            .size(vh(state.size, 20.0))
            .color(p::base05()),
        text("do you wanna use the TV?")
            .font(font::DEFAULT)
            .size(vh(state.size, 10.0))
            .color(p::base04()),
    ]
    .spacing(vh(state.size, 7.0))
    .align_x(Center)
    .into()
}
