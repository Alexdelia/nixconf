use iced::{
    Color, Rectangle, Renderer, Size, Theme, mouse,
    widget::canvas::{Action, Event, Frame, Geometry, Path, Program, Stroke},
};

use widget::palette as p;

use crate::{
    geometry::{Handle, Point, Rect},
    overlay::Message,
};

const DIM_ALPHA: f32 = 0.5;
const BORDER: f32 = 2.0;
const HANDLE: f32 = 8.0;

pub struct Overlay<'a> {
    pub output: &'a str,
    pub rect: Option<Rect>,
}

fn point_of(position: iced::Point) -> Point {
    Point {
        x: position.x.round() as i32,
        y: position.y.round() as i32,
    }
}

fn handle_center(rect: Rect) -> [iced::Point; 8] {
    let left = rect.x as f32;
    let top = rect.y as f32;
    let right = left + rect.width as f32;
    let bottom = top + rect.height as f32;
    let middle_x = (left + right) / 2.0;
    let middle_y = (top + bottom) / 2.0;
    [
        (left, top),
        (middle_x, top),
        (right, top),
        (right, middle_y),
        (right, bottom),
        (middle_x, bottom),
        (left, bottom),
        (left, middle_y),
    ]
    .map(|(x, y)| iced::Point::new(x, y))
}

fn dim(frame: &mut Frame, bounds: Rectangle, rect: Rect) {
    let color = Color {
        a: DIM_ALPHA,
        ..p::base00()
    };
    let left = rect.x as f32;
    let top = rect.y as f32;
    let right = left + rect.width as f32;
    let bottom = top + rect.height as f32;
    let height = rect.height as f32;
    [
        (0.0, 0.0, bounds.width, top),
        (0.0, bottom, bounds.width, bounds.height - bottom),
        (0.0, top, left, height),
        (right, top, bounds.width - right, height),
    ]
    .into_iter()
    .for_each(|(x, y, width, height)| {
        frame.fill_rectangle(iced::Point::new(x, y), Size::new(width, height), color);
    });
}

impl Program<Message> for Overlay<'_> {
    type State = ();

    fn update(
        &self,
        _state: &mut Self::State,
        event: &Event,
        bounds: Rectangle,
        cursor: mouse::Cursor,
    ) -> Option<Action<Message>> {
        let point = point_of(cursor.position_in(bounds)?);
        let output = self.output.to_owned();
        let message = match event {
            Event::Mouse(mouse::Event::ButtonPressed(mouse::Button::Left)) => {
                Message::Press(output, point)
            }
            Event::Mouse(mouse::Event::CursorMoved { .. }) => Message::Drag(output, point),
            Event::Mouse(mouse::Event::ButtonReleased(mouse::Button::Left)) => Message::Release,
            _ => return None,
        };
        Some(Action::publish(message).and_capture())
    }

    fn draw(
        &self,
        _state: &Self::State,
        renderer: &Renderer,
        _theme: &Theme,
        bounds: Rectangle,
        _cursor: mouse::Cursor,
    ) -> Vec<Geometry> {
        let mut frame = Frame::new(renderer, bounds.size());
        let Some(rect) = self.rect else {
            frame.fill_rectangle(
                iced::Point::ORIGIN,
                bounds.size(),
                Color {
                    a: DIM_ALPHA,
                    ..p::base00()
                },
            );
            return vec![frame.into_geometry()];
        };

        dim(&mut frame, bounds, rect);
        frame.stroke(
            &Path::rectangle(
                iced::Point::new(rect.x as f32, rect.y as f32),
                Size::new(rect.width as f32, rect.height as f32),
            ),
            Stroke::default().with_color(p::base0d()).with_width(BORDER),
        );
        for center in handle_center(rect) {
            frame.fill_rectangle(
                iced::Point::new(center.x - HANDLE / 2.0, center.y - HANDLE / 2.0),
                Size::new(HANDLE, HANDLE),
                p::base0d(),
            );
        }
        vec![frame.into_geometry()]
    }

    fn mouse_interaction(
        &self,
        _state: &Self::State,
        bounds: Rectangle,
        cursor: mouse::Cursor,
    ) -> mouse::Interaction {
        let handle = cursor
            .position_in(bounds)
            .zip(self.rect)
            .and_then(|(position, rect)| rect.handle_at(point_of(position)));
        match handle {
            Some(Handle::Left | Handle::Right) => mouse::Interaction::ResizingHorizontally,
            Some(Handle::Top | Handle::Bottom) => mouse::Interaction::ResizingVertically,
            Some(Handle::TopLeft | Handle::BottomRight) => {
                mouse::Interaction::ResizingDiagonallyDown
            }
            Some(Handle::TopRight | Handle::BottomLeft) => mouse::Interaction::ResizingDiagonallyUp,
            None => mouse::Interaction::Crosshair,
        }
    }
}
