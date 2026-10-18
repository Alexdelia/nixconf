use iced::Font;

pub const DEFAULT: Font = Font::with_name(crate::build_env!(
    "WIDGET_FONT_DEFAULT",
    "Maple Mono NL" // "RobotoMono Nerd Font",
));
pub const NUMERIC: Font =
    Font::with_name(crate::build_env!("WIDGET_FONT_NUMERIC", "Maple Mono NL"));
pub const SYMBOL: Font = Font::with_name(crate::build_env!(
    "WIDGET_FONT_SYMBOL",
    "RobotoMono Nerd Font Propo"
));
