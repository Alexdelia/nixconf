use iced::{Element, widget::row};

use widget::{button, unit::vh};

use crate::{Choice, Message, State};

pub fn view(state: &State) -> Element<'static, Message> {
    let size = vh(state.size, 20.0);
    row![
        option("no", Choice::No, size, state.selected),
        option("yes", Choice::Yes, size, state.selected),
    ]
    .spacing(vh(state.size, 10.0))
    .into()
}

fn option(
    label: &'static str,
    choice: Choice,
    size: f32,
    selected: Choice,
) -> Element<'static, Message> {
    button::text(label, size, choice == selected)
        .on_press(Message::Choose(choice))
        .into()
}
