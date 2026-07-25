use std::process::Command;

pub fn open() {
    if let Ok(command) = std::env::var("WIDGET_POWER_MENU") {
        let _ = Command::new(command).spawn();
    }
}
