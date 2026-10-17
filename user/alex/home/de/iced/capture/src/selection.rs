use crate::{
    geometry::{Handle, Point, Rect},
    memory::Saved,
};

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Drag {
    Resize {
        output: String,
        handle: Handle,
        origin: Rect,
    },
    New {
        output: String,
        start: Point,
    },
}

#[derive(Debug, Default)]
pub struct Selection {
    pub current: Option<Saved>,
    pub drag: Option<Drag>,
}

impl Selection {
    pub fn new(saved: Option<Saved>) -> Selection {
        Selection {
            current: saved,
            drag: None,
        }
    }

    pub fn press(&mut self, output: &str, point: Point) {
        let grabbed = self
            .on(output)
            .and_then(|rect| rect.handle_at(point).map(|handle| (rect, handle)));
        self.drag = Some(match grabbed {
            Some((origin, handle)) => Drag::Resize {
                output: output.to_owned(),
                handle,
                origin,
            },
            None => {
                self.current = None;
                Drag::New {
                    output: output.to_owned(),
                    start: point,
                }
            }
        });
    }

    pub fn drag_to(&mut self, output: &str, point: Point) {
        let rect = match &self.drag {
            Some(Drag::Resize {
                output: pressed,
                handle,
                origin,
            }) if pressed == output => origin.resize(*handle, point),
            Some(Drag::New {
                output: pressed,
                start,
            }) if pressed == output => Rect::from_drag(*start, point),
            _ => None,
        };
        if let Some(rect) = rect {
            self.current = Some(Saved {
                output: output.to_owned(),
                rect,
            });
        }
    }

    pub fn release(&mut self) {
        self.drag = None;
    }

    pub fn on(&self, output: &str) -> Option<Rect> {
        self.current
            .as_ref()
            .filter(|saved| saved.output == output)
            .map(|saved| saved.rect)
    }
}

#[cfg(test)]
mod test {
    use super::*;

    fn point(x: i32, y: i32) -> Point {
        Point { x, y }
    }

    fn saved(output: &str, x: i32, y: i32, width: i32, height: i32) -> Saved {
        Saved {
            output: output.to_owned(),
            rect: Rect {
                x,
                y,
                width,
                height,
            },
        }
    }

    fn selection() -> Selection {
        Selection::new(Some(saved("DP-1", 100, 100, 200, 100)))
    }

    #[test]
    fn press_on_handle_resizes() {
        let mut selection = selection();
        selection.press("DP-1", point(300, 150));
        selection.drag_to("DP-1", point(400, 999));
        selection.release();
        assert_eq!(selection.current, Some(saved("DP-1", 100, 100, 300, 100)));
        assert_eq!(selection.drag, None);
    }

    #[test]
    fn resize_past_opposite_edge_keeps_fixed_edge() {
        let mut selection = selection();
        selection.press("DP-1", point(100, 150));
        selection.drag_to("DP-1", point(350, 150));
        selection.drag_to("DP-1", point(360, 150));
        assert_eq!(selection.current, Some(saved("DP-1", 300, 100, 60, 100)));
    }

    #[test]
    fn press_inside_starts_new_selection() {
        let mut selection = selection();
        selection.press("DP-1", point(200, 150));
        assert_eq!(selection.current, None);
        selection.drag_to("DP-1", point(250, 180));
        assert_eq!(selection.current, Some(saved("DP-1", 200, 150, 50, 30)));
    }

    #[test]
    fn press_on_other_output_starts_new_selection_there() {
        let mut selection = selection();
        selection.press("HDMI-A-1", point(10, 10));
        selection.drag_to("HDMI-A-1", point(60, 40));
        assert_eq!(selection.current, Some(saved("HDMI-A-1", 10, 10, 50, 30)));
        assert_eq!(selection.on("DP-1"), None);
    }

    #[test]
    fn drag_on_other_output_is_ignored() {
        let mut selection = selection();
        selection.press("DP-1", point(10, 10));
        selection.drag_to("DP-1", point(60, 40));
        selection.drag_to("HDMI-A-1", point(500, 500));
        assert_eq!(selection.current, Some(saved("DP-1", 10, 10, 50, 30)));
    }

    #[test]
    fn degenerate_resize_keeps_previous() {
        let mut selection = selection();
        selection.press("DP-1", point(100, 150));
        selection.drag_to("DP-1", point(300, 150));
        assert_eq!(selection.current, Some(saved("DP-1", 100, 100, 200, 100)));
    }

    #[test]
    fn click_without_move_leaves_nothing() {
        let mut selection = selection();
        selection.press("DP-1", point(10, 10));
        selection.release();
        assert_eq!(selection.current, None);
    }

    #[test]
    fn drag_without_press_does_nothing() {
        let mut selection = selection();
        selection.drag_to("DP-1", point(5, 5));
        assert_eq!(selection.current, Some(saved("DP-1", 100, 100, 200, 100)));
    }

    #[test]
    fn on_returns_rect_only_for_its_output() {
        let selection = selection();
        assert_eq!(
            selection.on("DP-1"),
            Some(saved("DP-1", 100, 100, 200, 100).rect)
        );
        assert_eq!(selection.on("HDMI-A-1"), None);
    }
}
