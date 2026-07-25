use iced::advanced::Renderer as _;
use iced::advanced::renderer;
use iced::{Background, Border, Color, Rectangle, Shadow, border};

use widget::animation::Lerp;
use widget::button::Palette;

pub fn paint(
    renderer: &mut iced::Renderer,
    bounds: Rectangle,
    radius: f32,
    color: &Palette,
    progress: f32,
) -> Color {
    let background = color.idle_off.lerp(color.hover, progress);

    renderer.fill_quad(
        renderer::Quad {
            bounds,
            border: Border {
                radius: border::bottom_left(radius),
                ..Default::default()
            },
            shadow: Shadow::default(),
            snap: false,
        },
        Background::Color(background),
    );

    color.text_off.lerp(color.text_on, progress)
}
