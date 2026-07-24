use iced::{Element, widget::row};

use widget::{button, unit::vh};

use crate::{Message, State};

pub fn view(state: &State) -> Element<'_, Message> {
    let size = vh(state.size, 16.0);
    let ready = !state.password.is_empty();

    let no = button::text("no", size, false).on_press(Message::Cancel);
    let yes = button::text("yes", size, ready);
    let yes = if ready {
        yes.on_press(Message::Submit)
    } else {
        yes
    };

    row![no, yes].spacing(vh(state.size, 10.0)).into()
}
