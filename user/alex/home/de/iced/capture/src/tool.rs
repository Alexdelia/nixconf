use std::process::Command;

pub fn grim() -> &'static str {
    option_env!("CAPTURE_GRIM").unwrap_or("grim")
}

pub fn wf_recorder() -> &'static str {
    option_env!("CAPTURE_WF_RECORDER").unwrap_or("wf-recorder")
}

pub fn swaymsg() -> &'static str {
    option_env!("CAPTURE_SWAYMSG").unwrap_or("swaymsg")
}

pub fn makoctl() -> &'static str {
    option_env!("CAPTURE_MAKOCTL").unwrap_or("makoctl")
}

pub fn mako_mode() -> &'static str {
    option_env!("CAPTURE_MAKO_MODE").unwrap_or("do-not-disturb")
}

pub fn notify_send() -> &'static str {
    option_env!("CAPTURE_NOTIFY_SEND").unwrap_or("notify-send")
}

pub fn clipboard_copy() -> String {
    std::env::var("CAPTURE_CLIPBOARD_COPY").unwrap_or_else(|_| "wl-copy".to_owned())
}

pub fn fail(message: &str) -> ! {
    eprintln!("{message}");
    let _ = Command::new(notify_send())
        .args(["-u", "critical", message])
        .status();
    std::process::exit(1);
}
