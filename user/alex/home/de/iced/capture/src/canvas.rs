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
const BRACKET_GAP: f32 = 6.0;
const BRACKET_ARM: f32 = 20.0;

pub struct Overlay<'a> {
    pub output: &'a str,
    pub rect: Option<Rect>,
    pub bracket: bool,
}

fn point_of(position: iced::Point) -> Point {
    Point {
        x: position.x.round() as i32,
        y: position.y.round() as i32,
    }
}

fn bracket(rect: Rect) -> [[iced::Point; 3]; 4] {
    let offset = BORDER + BRACKET_GAP + BORDER / 2.0;
    let left = rect.x as f32 - offset;
    let top = rect.y as f32 - offset;
    let right = (rect.x + rect.width) as f32 + offset;
    let bottom = (rect.y + rect.height) as f32 + offset;
    [
        (left, top, 1.0, 1.0),
        (right, top, -1.0, 1.0),
        (right, bottom, -1.0, -1.0),
        (left, bottom, 1.0, -1.0),
    ]
    .map(|(x, y, inward_x, inward_y)| {
        [
            iced::Point::new(x, y + inward_y * BRACKET_ARM),
            iced::Point::new(x, y),
            iced::Point::new(x + inward_x * BRACKET_ARM, y),
        ]
    })
}

fn polyline(point: [iced::Point; 3]) -> Path {
    Path::new(|builder| {
        builder.move_to(point[0]);
        builder.line_to(point[1]);
        builder.line_to(point[2]);
    })
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

pub fn translate(
    output: &str,
    pressed: &mut bool,
    event: &Event,
    bounds: Rectangle,
    cursor: mouse::Cursor,
) -> Option<Message> {
    match event {
        Event::Mouse(mouse::Event::ButtonPressed(mouse::Button::Left)) => {
            let point = point_of(cursor.position_in(bounds)?);
            *pressed = true;
            Some(Message::Press(output.to_owned(), point))
        }
        Event::Mouse(mouse::Event::CursorMoved { .. }) if *pressed => {
            let position = cursor.position()?;
            let clamped = iced::Point::new(
                position.x.clamp(bounds.x, bounds.x + bounds.width) - bounds.x,
                position.y.clamp(bounds.y, bounds.y + bounds.height) - bounds.y,
            );
            Some(Message::Drag(output.to_owned(), point_of(clamped)))
        }
        Event::Mouse(mouse::Event::ButtonReleased(mouse::Button::Left)) if *pressed => {
            *pressed = false;
            Some(Message::Release)
        }
        _ => None,
    }
}

impl Program<Message> for Overlay<'_> {
    type State = bool;

    fn update(
        &self,
        pressed: &mut Self::State,
        event: &Event,
        bounds: Rectangle,
        cursor: mouse::Cursor,
    ) -> Option<Action<Message>> {
        translate(self.output, pressed, event, bounds, cursor)
            .map(|message| Action::publish(message).and_capture())
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
                iced::Point::new(rect.x as f32 - BORDER / 2.0, rect.y as f32 - BORDER / 2.0),
                Size::new(rect.width as f32 + BORDER, rect.height as f32 + BORDER),
            ),
            Stroke::default().with_color(p::base04()).with_width(BORDER),
        );
        if self.bracket {
            for corner in bracket(rect) {
                frame.stroke(
                    &polyline(corner),
                    Stroke::default().with_color(p::base08()).with_width(BORDER),
                );
            }
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

#[cfg(test)]
mod test {
    use super::*;

    fn bounds() -> Rectangle {
        Rectangle::new(iced::Point::ORIGIN, Size::new(100.0, 100.0))
    }

    fn at(x: f32, y: f32) -> mouse::Cursor {
        mouse::Cursor::Available(iced::Point::new(x, y))
    }

    fn press() -> Event {
        Event::Mouse(mouse::Event::ButtonPressed(mouse::Button::Left))
    }

    fn release() -> Event {
        Event::Mouse(mouse::Event::ButtonReleased(mouse::Button::Left))
    }

    fn moved(x: f32, y: f32) -> Event {
        Event::Mouse(mouse::Event::CursorMoved {
            position: iced::Point::new(x, y),
        })
    }

    fn selection() -> Rect {
        Rect {
            x: 100,
            y: 100,
            width: 200,
            height: 100,
        }
    }

    fn points(raw: [(f32, f32); 3]) -> [iced::Point; 3] {
        raw.map(|(x, y)| iced::Point::new(x, y))
    }

    #[test]
    fn bracket_sits_a_gap_outside_selection_border() {
        let offset = BORDER + BRACKET_GAP + BORDER / 2.0;
        let corner = bracket(selection());
        assert_eq!(
            corner[0],
            points([
                (100.0 - offset, 100.0 - offset + BRACKET_ARM),
                (100.0 - offset, 100.0 - offset),
                (100.0 - offset + BRACKET_ARM, 100.0 - offset),
            ])
        );
        assert_eq!(
            corner[2],
            points([
                (300.0 + offset, 200.0 + offset - BRACKET_ARM),
                (300.0 + offset, 200.0 + offset),
                (300.0 + offset - BRACKET_ARM, 200.0 + offset),
            ])
        );
    }

    #[test]
    fn bracket_arms_point_along_selection_edges() {
        for [first, corner, last] in bracket(selection()) {
            assert_eq!(first.x, corner.x);
            assert_eq!(last.y, corner.y);
            assert_eq!((first.y - corner.y).abs(), BRACKET_ARM);
            assert_eq!((last.x - corner.x).abs(), BRACKET_ARM);
        }
    }

    #[test]
    fn release_outside_surface_still_releases() {
        let mut pressed = true;
        let message = translate(
            "DP-1",
            &mut pressed,
            &release(),
            bounds(),
            mouse::Cursor::Unavailable,
        );
        assert!(matches!(message, Some(Message::Release)));
        assert!(!pressed);
    }

    #[test]
    fn drag_outside_surface_clamps_to_edge() {
        let mut pressed = true;
        let message = translate(
            "DP-1",
            &mut pressed,
            &moved(150.0, 40.0),
            bounds(),
            at(150.0, 40.0),
        );
        assert!(matches!(
            message,
            Some(Message::Drag(output, Point { x: 100, y: 40 })) if output == "DP-1"
        ));
    }

    #[test]
    fn hover_without_press_is_ignored() {
        let mut pressed = false;
        assert!(
            translate(
                "DP-1",
                &mut pressed,
                &moved(10.0, 10.0),
                bounds(),
                at(10.0, 10.0)
            )
            .is_none()
        );
        assert!(translate("DP-1", &mut pressed, &release(), bounds(), at(10.0, 10.0)).is_none());
    }

    #[test]
    fn press_inside_starts_drag() {
        let mut pressed = false;
        let message = translate("DP-1", &mut pressed, &press(), bounds(), at(10.0, 20.0));
        assert!(matches!(
            message,
            Some(Message::Press(_, Point { x: 10, y: 20 }))
        ));
        assert!(pressed);
    }

    #[test]
    fn press_outside_surface_is_ignored() {
        let mut pressed = false;
        assert!(translate("DP-1", &mut pressed, &press(), bounds(), at(150.0, 20.0)).is_none());
        assert!(!pressed);
    }
}
