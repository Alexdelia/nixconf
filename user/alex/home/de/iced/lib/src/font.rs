use iced::Font;

const fn name(env: Option<&'static str>, fallback: &'static str) -> &'static str {
    match env {
        Some(v) => v,
        None => fallback,
    }
}

pub const DEFAULT: Font = Font::with_name(name(
    option_env!("WIDGET_FONT_DEFAULT"),
    "Maple Mono NL",
    // "RobotoMono Nerd Font",
));
pub const NUMERIC: Font =
    Font::with_name(name(option_env!("WIDGET_FONT_NUMERIC"), "Maple Mono NL"));
pub const SYMBOL: Font = Font::with_name(name(
    option_env!("WIDGET_FONT_SYMBOL"),
    "RobotoMono Nerd Font Propo",
));
