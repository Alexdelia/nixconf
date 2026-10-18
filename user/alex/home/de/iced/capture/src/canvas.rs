use std::f32::consts::PI;

use iced::{
    Color, Radians, Rectangle, Renderer, Size, Theme, mouse,
    widget::canvas::{Action, Event, Frame, Geometry, Path, Program, Stroke, path::Arc},
};

use widget::palette as p;

use crate::{
    geometry::{Handle, Point, Rect},
    overlay::Message,
};

const DIM_ALPHA: f32 = 0.5;
const BORDER: f32 = 2.0;
const HANDLE_RADIUS: f32 = 7.0;

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

const HANDLE: [Handle; 8] = [
    Handle::TopLeft,
    Handle::Top,
    Handle::TopRight,
    Handle::Right,
    Handle::BottomRight,
    Handle::Bottom,
    Handle::BottomLeft,
    Handle::Left,
];

struct Wedge {
    center: iced::Point,
    start: f32,
    sweep: f32,
}

fn wedge(rect: Rect, handle: Handle) -> Wedge {
    let left = rect.x as f32;
    let top = rect.y as f32;
    let right = left + rect.width as f32;
    let bottom = top + rect.height as f32;
    let middle_x = (left + right) / 2.0;
    let middle_y = (top + bottom) / 2.0;
    let (x, y, outward) = match handle {
        Handle::Right => (right, middle_y, 0.0),
        Handle::BottomRight => (right, bottom, 0.25),
        Handle::Bottom => (middle_x, bottom, 0.5),
        Handle::BottomLeft => (left, bottom, 0.75),
        Handle::Left => (left, middle_y, 1.0),
        Handle::TopLeft => (left, top, 1.25),
        Handle::Top => (middle_x, top, 1.5),
        Handle::TopRight => (right, top, 1.75),
    };
    let sweep = match handle {
        Handle::Top | Handle::Right | Handle::Bottom | Handle::Left => PI,
        Handle::TopLeft | Handle::TopRight | Handle::BottomLeft | Handle::BottomRight => 1.5 * PI,
    };
    Wedge {
        center: iced::Point::new(x, y),
        start: outward * PI - sweep / 2.0,
        sweep,
    }
}

fn wedge_path(wedge: &Wedge) -> Path {
    Path::new(|builder| {
        builder.move_to(wedge.center);
        builder.arc(Arc {
            center: wedge.center,
            radius: HANDLE_RADIUS,
            start_angle: Radians(wedge.start),
            end_angle: Radians(wedge.start + wedge.sweep),
        });
        builder.close();
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
        for handle in HANDLE {
            frame.fill(&wedge_path(&wedge(rect, handle)), p::base04());
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

    fn strictly_inside(rect: Rect, point: iced::Point) -> bool {
        const TOLERANCE: f32 = 0.01;
        point.x > rect.x as f32 + TOLERANCE
            && point.x < (rect.x + rect.width) as f32 - TOLERANCE
            && point.y > rect.y as f32 + TOLERANCE
            && point.y < (rect.y + rect.height) as f32 - TOLERANCE
    }

    #[test]
    fn handle_wedge_stays_outside_selection() {
        const STEP: u16 = 64;
        for handle in HANDLE {
            let wedge = wedge(selection(), handle);
            for step in 0..=STEP {
                let angle = wedge.start + wedge.sweep * f32::from(step) / f32::from(STEP);
                for radius in [0.5, HANDLE_RADIUS] {
                    let point = iced::Point::new(
                        wedge.center.x + radius * angle.cos(),
                        wedge.center.y + radius * angle.sin(),
                    );
                    assert!(
                        !strictly_inside(selection(), point),
                        "{handle:?} reaches inside at {point:?}"
                    );
                }
            }
        }
    }

    #[test]
    fn handle_wedge_is_half_on_edge_three_quarter_on_corner() {
        for handle in HANDLE {
            let expected = match handle {
                Handle::Top | Handle::Right | Handle::Bottom | Handle::Left => PI,
                _ => 1.5 * PI,
            };
            assert!((wedge(selection(), handle).sweep - expected).abs() < 1e-6);
        }
    }

    #[test]
    fn handle_wedge_sits_on_its_edge() {
        let rect = selection();
        assert_eq!(
            wedge(rect, Handle::TopLeft).center,
            iced::Point::new(100.0, 100.0)
        );
        assert_eq!(
            wedge(rect, Handle::Right).center,
            iced::Point::new(300.0, 150.0)
        );
        assert_eq!(
            wedge(rect, Handle::Bottom).center,
            iced::Point::new(200.0, 200.0)
        );
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
