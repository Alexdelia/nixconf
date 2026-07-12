use iced::{
    Background, Border, Center, Element,
    Length::{Fill, FillPortion},
    widget::{Space, column, container, row},
};

use widget::{palette as p, unit::vh};

use crate::{Message, State, action, prompt};

pub fn view(state: &State) -> Element<'_, Message> {
    let radius = vh(state.size, 2.0);
    let card = container(
        column![prompt::view(state), action::view(state),]
            .spacing(vh(state.size, 10.0))
            .align_x(Center),
    )
    .padding(vh(state.size, 4.0))
    .center_x(FillPortion(8))
    .center_y(Fill)
    .style(move |_theme| container::Style {
        background: Some(Background::Color(p::base01())),
        border: Border {
            radius: radius.into(),
            width: 1.0,
            color: p::base0d(),
        },
        text_color: Some(p::base05()),
        ..Default::default()
    });

    column![
        Space::new().height(FillPortion(1)),
        row![
            Space::new().width(FillPortion(1)),
            card,
            Space::new().width(FillPortion(1)),
        ]
        .width(Fill)
        .height(FillPortion(8)),
        Space::new().height(FillPortion(1)),
    ]
    .width(Fill)
    .height(Fill)
    .into()
}
