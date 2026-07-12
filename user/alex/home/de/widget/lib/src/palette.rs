use iced::Color;

pub fn hex(s: &str) -> Color {
    let s = s.trim_start_matches('#');
    let v = u32::from_str_radix(s, 16).unwrap_or(0);
    Color::from_rgb8((v >> 16) as u8, (v >> 8) as u8, v as u8)
}

macro_rules! bases {
    ($($name:ident => $env:literal, $fallback:literal;)*) => {
        $(
            pub fn $name() -> Color {
                const HEX: &str = match option_env!($env) {
                    Some(v) => v,
                    None => $fallback,
                };
                hex(HEX)
            }
        )*
    };
}

bases! {
    base00 => "WIDGET_BASE00", "#111111";
    base01 => "WIDGET_BASE01", "#202020";
    base02 => "WIDGET_BASE02", "#333333";
    base03 => "WIDGET_BASE03", "#5a4763";
    base04 => "WIDGET_BASE04", "#808080";
    base05 => "WIDGET_BASE05", "#e0e0e0";
    base06 => "WIDGET_BASE06", "#ffd1ff";
    base07 => "WIDGET_BASE07", "#ffffff";
    base08 => "WIDGET_BASE08", "#d32f2f";
    base09 => "WIDGET_BASE09", "#ff9800";
    base0a => "WIDGET_BASE0A", "#b6d025";
    base0b => "WIDGET_BASE0B", "#47d823";
    base0c => "WIDGET_BASE0C", "#5ed5ed";
    base0d => "WIDGET_BASE0D", "#19a1e6";
    base0e => "WIDGET_BASE0E", "#a020f0";
    base0f => "WIDGET_BASE0F", "#960707";
    base10 => "WIDGET_BASE10", "#0c0c0c";
    base11 => "WIDGET_BASE11", "#110214";
    base12 => "WIDGET_BASE12", "#ff0000";
    base13 => "WIDGET_BASE13", "#ffdb38";
    base14 => "WIDGET_BASE14", "#7aff00";
    base15 => "WIDGET_BASE15", "#7ffcf9";
    base16 => "WIDGET_BASE16", "#5700ff";
    base17 => "WIDGET_BASE17", "#ff00ff";
}
