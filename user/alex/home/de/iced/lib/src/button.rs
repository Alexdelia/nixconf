use iced::advanced::layout::{self, Layout};
use iced::advanced::renderer;
use iced::advanced::widget::{Tree, tree};
use iced::advanced::{Clipboard, Renderer as _, Shell, Widget, mouse};
use iced::time::Instant;
use iced::{
    Background, Border, Color, Element, Event, Font, Length, Padding, Point, Rectangle, Shadow,
    Size, Theme, window,
};

use crate::animation::{Fade, Lerp};
use crate::{font, palette as p};

const HOVER_ALPHA: f32 = 0.5;

const PADDING_RATIO: f32 = 0.3;
// lowercase-only labels leave the cap/ascender zone empty, so trim the top to re-center
const PADDING_TOP_RATIO: f32 = 0.1;

const RADIUS_RATIO: f32 = 0.3;

const ICON_GLYPH_RATIO: f32 = 3.0 / 4.0;
const ICON_RADIUS_RATIO: f32 = 1.0 / 4.0;

pub const FADE_MS: u64 = 300;

pub fn icon_palette() -> Palette {
    Palette {
        idle_off: p::base01(),
        idle_on: p::base01(),
        hover: p::base02(),
        text_off: p::base05(),
        text_on: p::base0e(),
    }
}

pub fn icon<'a, Message: Clone + 'a>(
    label: &'a str,
    side: f32,
    selected: bool,
) -> AnimatedButton<'a, Message> {
    let mut button = AnimatedButton::new(
        label,
        side * ICON_GLYPH_RATIO,
        selected,
        font::SYMBOL,
        icon_palette(),
    );
    button.side = Some(side);
    button.radius = side * ICON_RADIUS_RATIO;
    button
}

pub fn text<'a, Message: Clone + 'a>(
    label: &'a str,
    size: f32,
    selected: bool,
) -> AnimatedButton<'a, Message> {
    AnimatedButton::new(
        label,
        size,
        selected,
        font::DEFAULT,
        Palette {
            idle_off: p::base02(),
            idle_on: p::base0b(),
            hover: p::base0b().scale_alpha(HOVER_ALPHA),
            text_off: p::base05(),
            text_on: p::base01(),
        },
    )
}

pub struct Palette {
    pub idle_off: Color,
    pub idle_on: Color,
    pub hover: Color,
    pub text_off: Color,
    pub text_on: Color,
}

pub struct AnimatedButton<'a, Message> {
    content: Element<'a, Message>,
    on_press: Option<Message>,
    selected: bool,
    color: Palette,
    radius: f32,
    padding: Padding,
    side: Option<f32>,
}

impl<'a, Message: 'a> AnimatedButton<'a, Message> {
    fn new(label: &'a str, size: f32, selected: bool, font: Font, color: Palette) -> Self {
        Self {
            content: iced::widget::text(label)
                .size(size)
                .font(font)
                .line_height(1.0)
                .center()
                .into(),
            on_press: None,
            selected,
            color,
            radius: size * RADIUS_RATIO,
            padding: Padding {
                top: size * PADDING_TOP_RATIO,
                right: size * PADDING_RATIO,
                bottom: size * PADDING_RATIO,
                left: size * PADDING_RATIO,
            },
            side: None,
        }
    }

    pub fn on_press(mut self, message: Message) -> Self {
        self.on_press = Some(message);
        self
    }
}

struct State {
    is_pressed: bool,
    hovered: bool,
    hover: Fade,
    selection: Fade,
    now: Instant,
}

impl<'a, Message: Clone + 'a> Widget<Message, Theme, iced::Renderer>
    for AnimatedButton<'a, Message>
{
    fn tag(&self) -> tree::Tag {
        tree::Tag::of::<State>()
    }

    fn state(&self) -> tree::State {
        tree::State::new(State {
            is_pressed: false,
            hovered: false,
            hover: Fade::new(false, FADE_MS),
            selection: Fade::new(self.selected, FADE_MS),
            now: Instant::now(),
        })
    }

    fn children(&self) -> Vec<Tree> {
        vec![Tree::new(&self.content)]
    }

    fn diff(&self, tree: &mut Tree) {
        tree.diff_children(std::slice::from_ref(&self.content));
    }

    fn size(&self) -> Size<Length> {
        match self.side {
            Some(side) => Size {
                width: Length::Fixed(side),
                height: Length::Fixed(side),
            },
            None => Size {
                width: Length::Shrink,
                height: Length::Shrink,
            },
        }
    }

    fn layout(
        &mut self,
        tree: &mut Tree,
        renderer: &iced::Renderer,
        limits: &layout::Limits,
    ) -> layout::Node {
        match self.side {
            Some(side) => {
                let square = Size::new(side, side);
                let content = self.content.as_widget_mut().layout(
                    &mut tree.children[0],
                    renderer,
                    &layout::Limits::new(Size::ZERO, square),
                );
                let glyph = content.size();
                let content = content.move_to(Point::new(
                    (side - glyph.width) / 2.0,
                    (side - glyph.height) / 2.0,
                ));
                layout::Node::with_children(square, vec![content])
            }
            None => layout::padded(
                limits,
                Length::Shrink,
                Length::Shrink,
                self.padding,
                |limits| {
                    self.content
                        .as_widget_mut()
                        .layout(&mut tree.children[0], renderer, limits)
                },
            ),
        }
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
        let bounds = layout.bounds();
        let over = cursor.is_over(bounds);
        let state = tree.state.downcast_mut::<State>();

        match event {
            Event::Mouse(mouse::Event::ButtonPressed(mouse::Button::Left))
                if self.on_press.is_some() && over =>
            {
                state.is_pressed = true;
                shell.capture_event();
            }
            Event::Mouse(mouse::Event::ButtonReleased(mouse::Button::Left)) => {
                if let Some(on_press) = &self.on_press
                    && state.is_pressed
                {
                    state.is_pressed = false;
                    if over {
                        shell.publish(on_press.clone());
                    }
                    shell.capture_event();
                }
            }
            _ => {}
        }

        if state.hovered != over {
            state.hovered = over;
            shell.request_redraw();
        }

        if let Event::Window(window::Event::RedrawRequested(now)) = event {
            state.now = *now;
            state.hover.to(state.hovered, *now);
            state.selection.to(self.selected, *now);
            if state.hover.is_animating(*now) || state.selection.is_animating(*now) {
                shell.request_redraw();
            }
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
        let bounds = layout.bounds();
        let content_layout = layout.children().next().unwrap();

        let selection_progress = state.selection.progress(state.now);
        let hover_progress = state.hover.progress(state.now);

        let idle = self
            .color
            .idle_off
            .lerp(self.color.idle_on, selection_progress);
        let background = idle.lerp(self.color.hover, hover_progress);
        let text_color = self
            .color
            .text_off
            .lerp(self.color.text_on, selection_progress);

        renderer.fill_quad(
            renderer::Quad {
                bounds,
                border: Border {
                    radius: self.radius.into(),
                    ..Default::default()
                },
                shadow: Shadow::default(),
                snap: false,
            },
            Background::Color(background),
        );

        self.content.as_widget().draw(
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
        if cursor.is_over(layout.bounds()) && self.on_press.is_some() {
            mouse::Interaction::Pointer
        } else {
            mouse::Interaction::default()
        }
    }
}

impl<'a, Message: Clone + 'a> From<AnimatedButton<'a, Message>> for Element<'a, Message> {
    fn from(button: AnimatedButton<'a, Message>) -> Self {
        Element::new(button)
    }
}
