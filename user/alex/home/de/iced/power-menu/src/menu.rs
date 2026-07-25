use iced::{
    Center, Element, Fill,
    widget::{container, row},
};

use widget::{button, unit::vh};

use crate::{ENTRY, Message, State};

const SIDE_VH: f32 = 22.0;
const GAP_VH: f32 = 3.0;

pub fn view(state: &State) -> Element<'_, Message> {
    let side = vh(state.size, SIDE_VH);

    let entry = ENTRY.iter().enumerate().map(|(index, entry)| {
        button::icon(entry.glyph, side, index == state.selected)
            .on_press(Message::Activate(index))
            .into()
    });

    container(row(entry).spacing(vh(state.size, GAP_VH)).align_y(Center))
        .width(Fill)
        .height(Fill)
        .align_x(Center)
        .align_y(Center)
        .into()
}
