use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct Rect {
    pub x: i32,
    pub y: i32,
    pub width: i32,
    pub height: i32,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Point {
    pub x: i32,
    pub y: i32,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Handle {
    Top,
    Bottom,
    Left,
    Right,
    TopLeft,
    TopRight,
    BottomLeft,
    BottomRight,
}

pub const GRAB: i32 = 12;

struct Edge {
    left: i32,
    top: i32,
    right: i32,
    bottom: i32,
}

impl Edge {
    fn rect(&self) -> Option<Rect> {
        Rect::from_drag(
            Point {
                x: self.left,
                y: self.top,
            },
            Point {
                x: self.right,
                y: self.bottom,
            },
        )
    }
}

fn near(value: i32, edge: i32) -> bool {
    (value - edge).abs() <= GRAB
}

fn between(value: i32, low: i32, high: i32) -> bool {
    low - GRAB <= value && value <= high + GRAB
}

impl Rect {
    pub fn from_drag(start: Point, end: Point) -> Option<Rect> {
        let rect = Rect {
            x: start.x.min(end.x),
            y: start.y.min(end.y),
            width: (start.x - end.x).abs(),
            height: (start.y - end.y).abs(),
        };
        (rect.width > 0 && rect.height > 0).then_some(rect)
    }

    fn edge(&self) -> Edge {
        Edge {
            left: self.x,
            top: self.y,
            right: self.x + self.width,
            bottom: self.y + self.height,
        }
    }

    pub fn handle_at(&self, point: Point) -> Option<Handle> {
        let edge = self.edge();
        if !between(point.x, edge.left, edge.right) || !between(point.y, edge.top, edge.bottom) {
            return None;
        }
        let left = near(point.x, edge.left);
        let right = near(point.x, edge.right);
        let top = near(point.y, edge.top);
        let bottom = near(point.y, edge.bottom);
        match (left, right, top, bottom) {
            (true, _, true, _) => Some(Handle::TopLeft),
            (_, true, true, _) => Some(Handle::TopRight),
            (true, _, _, true) => Some(Handle::BottomLeft),
            (_, true, _, true) => Some(Handle::BottomRight),
            (true, ..) => Some(Handle::Left),
            (_, true, ..) => Some(Handle::Right),
            (_, _, true, _) => Some(Handle::Top),
            (.., true) => Some(Handle::Bottom),
            _ => None,
        }
    }

    pub fn resize(&self, handle: Handle, point: Point) -> Option<Rect> {
        let mut edge = self.edge();
        match handle {
            Handle::Top | Handle::TopLeft | Handle::TopRight => edge.top = point.y,
            Handle::Bottom | Handle::BottomLeft | Handle::BottomRight => edge.bottom = point.y,
            Handle::Left | Handle::Right => {}
        }
        match handle {
            Handle::Left | Handle::TopLeft | Handle::BottomLeft => edge.left = point.x,
            Handle::Right | Handle::TopRight | Handle::BottomRight => edge.right = point.x,
            Handle::Top | Handle::Bottom => {}
        }
        edge.rect()
    }

    pub fn even(&self) -> Option<Rect> {
        let rect = Rect {
            width: self.width & !1,
            height: self.height & !1,
            ..*self
        };
        (rect.width > 0 && rect.height > 0).then_some(rect)
    }

    pub fn fits(&self, width: i32, height: i32) -> bool {
        let edge = self.edge();
        edge.left >= 0 && edge.top >= 0 && edge.right <= width && edge.bottom <= height
    }

    pub fn offset(&self, dx: i32, dy: i32) -> Rect {
        Rect {
            x: self.x + dx,
            y: self.y + dy,
            ..*self
        }
    }

    pub fn grim_geometry(&self) -> String {
        format!("{},{} {}x{}", self.x, self.y, self.width, self.height)
    }

    fn clip(&self, width: i32, height: i32) -> Option<Rect> {
        let edge = self.edge();
        Rect::from_drag(
            Point {
                x: edge.left.clamp(0, width),
                y: edge.top.clamp(0, height),
            },
            Point {
                x: edge.right.clamp(0, width),
                y: edge.bottom.clamp(0, height),
            },
        )
    }

    pub fn frame(&self, thickness: i32, width: i32, height: i32) -> Vec<Rect> {
        let edge = self.edge();
        let wide = self.width + 2 * thickness;
        [
            (edge.left - thickness, edge.top - thickness, wide, thickness),
            (edge.left - thickness, edge.bottom, wide, thickness),
            (edge.left - thickness, edge.top, thickness, self.height),
            (edge.right, edge.top, thickness, self.height),
        ]
        .into_iter()
        .filter_map(|(x, y, strip_width, strip_height)| {
            Rect {
                x,
                y,
                width: strip_width,
                height: strip_height,
            }
            .clip(width, height)
        })
        .collect()
    }
}

#[cfg(test)]
mod test {
    use super::*;

    fn point(x: i32, y: i32) -> Point {
        Point { x, y }
    }

    fn rect(x: i32, y: i32, width: i32, height: i32) -> Rect {
        Rect {
            x,
            y,
            width,
            height,
        }
    }

    #[test]
    fn from_drag_normalizes() {
        assert_eq!(
            Rect::from_drag(point(50, 40), point(10, 20)),
            Some(rect(10, 20, 40, 20))
        );
    }

    #[test]
    fn from_drag_rejects_degenerate() {
        assert_eq!(Rect::from_drag(point(10, 10), point(10, 10)), None);
        assert_eq!(Rect::from_drag(point(10, 10), point(10, 50)), None);
        assert_eq!(Rect::from_drag(point(10, 10), point(50, 10)), None);
    }

    #[test]
    fn handle_at_corner_wins_over_edge() {
        assert_eq!(
            rect(100, 100, 200, 100).handle_at(point(102, 98)),
            Some(Handle::TopLeft)
        );
    }

    #[test]
    fn handle_at_edge() {
        assert_eq!(
            rect(100, 100, 200, 100).handle_at(point(200, 199)),
            Some(Handle::Bottom)
        );
    }

    #[test]
    fn handle_at_inside_is_none() {
        assert_eq!(rect(100, 100, 200, 100).handle_at(point(200, 150)), None);
    }

    #[test]
    fn handle_at_outside_is_none() {
        assert_eq!(rect(100, 100, 200, 100).handle_at(point(50, 50)), None);
    }

    #[test]
    fn resize_right_moves_only_right() {
        assert_eq!(
            rect(100, 100, 200, 100).resize(Handle::Right, point(400, 0)),
            Some(rect(100, 100, 300, 100))
        );
    }

    #[test]
    fn resize_past_opposite_edge_flips() {
        assert_eq!(
            rect(100, 100, 200, 100).resize(Handle::Left, point(350, 0)),
            Some(rect(300, 100, 50, 100))
        );
    }

    #[test]
    fn resize_to_zero_is_none() {
        assert_eq!(
            rect(100, 100, 200, 100).resize(Handle::Left, point(300, 0)),
            None
        );
    }

    #[test]
    fn resize_corner_moves_both_axis() {
        assert_eq!(
            rect(100, 100, 200, 100).resize(Handle::BottomRight, point(400, 250)),
            Some(rect(100, 100, 300, 150))
        );
    }

    #[test]
    fn even_rounds_down() {
        assert_eq!(rect(0, 0, 301, 201).even(), Some(rect(0, 0, 300, 200)));
        assert_eq!(rect(0, 0, 1, 1).even(), None);
    }

    #[test]
    fn fits_inside_output() {
        assert!(rect(10, 10, 100, 100).fits(200, 200));
        assert!(!rect(150, 10, 100, 100).fits(200, 200));
        assert!(!rect(-1, 10, 100, 100).fits(200, 200));
    }

    #[test]
    fn offset_shifts_origin() {
        assert_eq!(rect(10, 20, 30, 40).offset(2560, 0), rect(2570, 20, 30, 40));
    }

    #[test]
    fn frame_surrounds_outside() {
        assert_eq!(
            rect(100, 100, 200, 100).frame(2, 1000, 1000),
            [
                rect(98, 98, 204, 2),
                rect(98, 200, 204, 2),
                rect(98, 100, 2, 100),
                rect(300, 100, 2, 100),
            ]
        );
    }

    #[test]
    fn frame_drops_strip_off_output() {
        let frame = rect(0, 0, 200, 100).frame(2, 200, 1000);
        assert_eq!(frame, [rect(0, 100, 200, 2)]);
    }

    #[test]
    fn grim_geometry_format() {
        assert_eq!(rect(10, 20, 300, 200).grim_geometry(), "10,20 300x200");
    }
}
