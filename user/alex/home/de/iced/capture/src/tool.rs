use std::process::Command;

pub const GRIM: &str = widget::build_env!("CAPTURE_GRIM", "grim");
pub const WF_RECORDER: &str = widget::build_env!("CAPTURE_WF_RECORDER", "wf-recorder");
pub const SWAYMSG: &str = widget::build_env!("CAPTURE_SWAYMSG", "swaymsg");
pub const MAKOCTL: &str = widget::build_env!("CAPTURE_MAKOCTL", "makoctl");
pub const MAKO_MODE: &str = widget::build_env!("CAPTURE_MAKO_MODE", "do-not-disturb");
pub const NOTIFY_SEND: &str = widget::build_env!("CAPTURE_NOTIFY_SEND", "notify-send");
pub const CLIPBOARD_COPY: &str = widget::build_env!("CAPTURE_CLIPBOARD_COPY", "wl-copy");

pub fn fail(message: &str) -> ! {
    eprintln!("{message}");
    let _ = Command::new(NOTIFY_SEND)
        .args(["-u", "critical", message])
        .status();
    std::process::exit(1);
}
