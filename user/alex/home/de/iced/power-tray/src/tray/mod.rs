mod render;
mod state;

use iced::advanced::layout::{self, Layout};
use iced::advanced::renderer;
use iced::advanced::widget::{Tree, tree};
use iced::advanced::{Clipboard, Shell, Widget, mouse};
use iced::{Element, Event, Length, Point, Rectangle, Size, Theme, window};

use widget::button::{Palette, icon_palette};
use widget::font;

use crate::Message;
use state::State;

const GLYPH: &str = "";

const GLYPH_RATIO: f32 = 3.0 / 5.0;
const RADIUS_RATIO: f32 = 1.0 / 2.0;

pub fn view(side: f32) -> Element<'static, Message> {
    Tray::new(side).into()
}

struct Tray {
    glyph: Element<'static, Message>,
    side: f32,
    radius: f32,
    color: Palette,
}

impl Tray {
    fn new(side: f32) -> Self {
        Self {
            glyph: iced::widget::text(GLYPH)
                .size(side * GLYPH_RATIO)
                .font(font::SYMBOL)
                .line_height(1.0)
                .center()
                .into(),
            side,
            radius: side * RADIUS_RATIO,
            color: icon_palette(),
        }
    }
}

impl Widget<Message, Theme, iced::Renderer> for Tray {
    fn tag(&self) -> tree::Tag {
        tree::Tag::of::<State>()
    }

    fn state(&self) -> tree::State {
        tree::State::new(State::default())
    }

    fn children(&self) -> Vec<Tree> {
        vec![Tree::new(&self.glyph)]
    }

    fn diff(&self, tree: &mut Tree) {
        tree.diff_children(std::slice::from_ref(&self.glyph));
    }

    fn size(&self) -> Size<Length> {
        Size {
            width: Length::Fixed(self.side),
            height: Length::Fixed(self.side),
        }
    }

    fn layout(
        &mut self,
        tree: &mut Tree,
        renderer: &iced::Renderer,
        _limits: &layout::Limits,
    ) -> layout::Node {
        let square = Size::new(self.side, self.side);
        let content = self.glyph.as_widget_mut().layout(
            &mut tree.children[0],
            renderer,
            &layout::Limits::new(Size::ZERO, square),
        );
        let glyph = content.size();
        let offset = GLYPH_RATIO * self.side / 16.0;
        let content = content.move_to(Point::new(
            (self.side - glyph.width) / 2.0 + offset,
            (self.side - glyph.height) / 2.0 - offset,
        ));
        layout::Node::with_children(square, vec![content])
    }

    fn update(
        &mut self,
        tree: &mut Tree,
        event: &Event,
        layout: Layout<'_>,
        cursor: mouse::Cursor,
        _renderer: &iced::Renderer,
        _clipboard: &mut dyn Clipboard,
        shell: &mut Shell<'_, Message>,
        _viewport: &Rectangle,
    ) {
        let over = cursor.is_over(layout.bounds());
        let state = tree.state.downcast_mut::<State>();

        match event {
            Event::Mouse(mouse::Event::ButtonPressed(mouse::Button::Left)) if over => {
                state.press();
                shell.capture_event();
            }
            Event::Mouse(mouse::Event::ButtonReleased(mouse::Button::Left)) if state.release() => {
                if over {
                    shell.publish(Message::Open);
                }
                shell.capture_event();
            }
            _ => {}
        }

        if state.hover(over) {
            shell.request_redraw();
        }

        if let Event::Window(window::Event::RedrawRequested(now)) = event
            && state.tick(*now)
        {
            shell.request_redraw();
        }
    }

    fn draw(
        &self,
        tree: &Tree,
        renderer: &mut iced::Renderer,
        theme: &Theme,
        _style: &renderer::Style,
        layout: Layout<'_>,
        cursor: mouse::Cursor,
        viewport: &Rectangle,
    ) {
        let state = tree.state.downcast_ref::<State>();
        let content_layout = layout.children().next().unwrap();

        let text_color = render::paint(
            renderer,
            layout.bounds(),
            self.radius,
            &self.color,
            state.progress(),
        );

        self.glyph.as_widget().draw(
            &tree.children[0],
            renderer,
            theme,
            &renderer::Style { text_color },
            content_layout,
            cursor,
            viewport,
        );
    }

    fn mouse_interaction(
        &self,
        _tree: &Tree,
        layout: Layout<'_>,
        cursor: mouse::Cursor,
        _viewport: &Rectangle,
        _renderer: &iced::Renderer,
    ) -> mouse::Interaction {
        if cursor.is_over(layout.bounds()) {
            mouse::Interaction::Pointer
        } else {
            mouse::Interaction::default()
        }
    }
}

impl From<Tray> for Element<'static, Message> {
    fn from(tray: Tray) -> Self {
        Element::new(tray)
    }
}
