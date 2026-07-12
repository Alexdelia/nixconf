use iced::Size;

pub fn vh(screen: Size, n: f32) -> f32 {
    screen.height * n / 100.0
}

pub fn vw(screen: Size, n: f32) -> f32 {
    screen.width * n / 100.0
}
