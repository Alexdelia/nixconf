use std::path::{Path, PathBuf};

use serde::{Deserialize, Serialize};

use crate::{Mode, geometry::Rect, output::Output};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Saved {
    pub output: String,
    pub rect: Rect,
}

fn state_home() -> PathBuf {
    std::env::var_os("XDG_STATE_HOME")
        .map(PathBuf::from)
        .unwrap_or_else(|| {
            PathBuf::from(std::env::var_os("HOME").unwrap_or_default()).join(".local/state")
        })
}

pub fn path(mode: Mode) -> PathBuf {
    state_home()
        .join(env!("CARGO_PKG_NAME"))
        .join(format!("{}.json", mode.name()))
}

pub fn load(file: &Path, outputs: &[Output]) -> Option<Saved> {
    let saved: Saved = serde_json::from_str(&std::fs::read_to_string(file).ok()?).ok()?;
    let output = outputs.iter().find(|output| output.name == saved.output)?;
    saved
        .rect
        .fits(output.rect.width, output.rect.height)
        .then_some(saved)
}

pub fn store(file: &Path, saved: &Saved) -> std::io::Result<()> {
    if let Some(parent) = file.parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(file, serde_json::to_string(saved)?)
}

#[cfg(test)]
mod test {
    use super::*;

    fn scratch(name: &str) -> PathBuf {
        let dir =
            std::env::temp_dir().join(format!("capture-test-memory-{}-{name}", std::process::id()));
        let _ = std::fs::remove_dir_all(&dir);
        dir.join("nested").join("screenshot.json")
    }

    fn output(name: &str, width: i32, height: i32) -> Output {
        Output {
            name: name.to_owned(),
            rect: Rect {
                x: 0,
                y: 0,
                width,
                height,
            },
        }
    }

    fn saved(output: &str, x: i32) -> Saved {
        Saved {
            output: output.to_owned(),
            rect: Rect {
                x,
                y: 0,
                width: 200,
                height: 100,
            },
        }
    }

    #[test]
    fn load_round_trip() {
        let file = scratch("round-trip");
        store(&file, &saved("DP-1", 10)).unwrap();
        assert_eq!(
            load(&file, &[output("DP-1", 2560, 1440)]),
            Some(saved("DP-1", 10))
        );
    }

    #[test]
    fn load_drops_missing_output() {
        let file = scratch("missing-output");
        store(&file, &saved("HDMI-A-1", 10)).unwrap();
        assert_eq!(load(&file, &[output("DP-1", 2560, 1440)]), None);
    }

    #[test]
    fn load_drops_rect_outside_output() {
        let file = scratch("outside");
        store(&file, &saved("DP-1", 2500)).unwrap();
        assert_eq!(load(&file, &[output("DP-1", 2560, 1440)]), None);
    }

    #[test]
    fn load_missing_or_corrupt_file_is_none() {
        let file = scratch("corrupt");
        assert_eq!(load(&file, &[output("DP-1", 2560, 1440)]), None);
        std::fs::create_dir_all(file.parent().unwrap()).unwrap();
        std::fs::write(&file, "{").unwrap();
        assert_eq!(load(&file, &[output("DP-1", 2560, 1440)]), None);
    }

    #[test]
    fn path_separate_per_mode() {
        let screenshot = path(Mode::Screenshot);
        let video = path(Mode::Video);
        assert_ne!(screenshot, video);
        assert!(screenshot.ends_with("capture/screenshot.json"));
        assert!(video.ends_with("capture/video.json"));
    }
}
