use iced::time::{Duration, Instant};
use iced::{Animation, Color};

pub trait Lerp {
    fn lerp(self, target: Self, progress: f32) -> Self;
}

impl Lerp for f32 {
    fn lerp(self, target: Self, progress: f32) -> Self {
        self + (target - self) * progress
    }
}

impl Lerp for Color {
    fn lerp(self, target: Self, progress: f32) -> Self {
        Color {
            r: self.r.lerp(target.r, progress),
            g: self.g.lerp(target.g, progress),
            b: self.b.lerp(target.b, progress),
            a: self.a.lerp(target.a, progress),
        }
    }
}

pub struct Fade {
    animation: Animation<bool>,
}

impl Fade {
    pub fn new(initial: bool, duration_ms: u64) -> Self {
        Self {
            animation: Animation::new(initial).duration(Duration::from_millis(duration_ms)),
        }
    }

    pub fn to(&mut self, target: bool, at: Instant) {
        if self.animation.value() != target {
            self.animation.go_mut(target, at);
        }
    }

    pub fn is_animating(&self, at: Instant) -> bool {
        self.animation.is_animating(at)
    }

    pub fn progress(&self, at: Instant) -> f32 {
        self.animation.interpolate(0.0, 1.0, at)
    }
}
