use iced::time::Instant;

use widget::animation::Fade;
use widget::button::FADE_MS;

pub struct State {
    is_pressed: bool,
    hovered: bool,
    hover: Fade,
    now: Instant,
}

impl Default for State {
    fn default() -> Self {
        Self {
            is_pressed: false,
            hovered: false,
            hover: Fade::new(false, FADE_MS),
            now: Instant::now(),
        }
    }
}

impl State {
    pub fn press(&mut self) {
        self.is_pressed = true;
    }

    pub fn release(&mut self) -> bool {
        let pressed = self.is_pressed;
        self.is_pressed = false;
        pressed
    }

    pub fn hover(&mut self, over: bool) -> bool {
        let changed = self.hovered != over;
        self.hovered = over;
        changed
    }

    pub fn tick(&mut self, now: Instant) -> bool {
        self.now = now;
        self.hover.to(self.hovered, now);
        self.hover.is_animating(now)
    }

    pub fn progress(&self) -> f32 {
        self.hover.progress(self.now)
    }
}
