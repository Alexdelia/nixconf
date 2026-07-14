use std::{process::Stdio, str::FromStr};

use iced::{
    futures::{SinkExt, Stream},
    stream,
};
use tokio::{
    io::{AsyncBufReadExt, BufReader},
    process::Command,
};

const WPCTL: &str = match option_env!("VOLUME_OSD_WPCTL") {
    Some(v) => v,
    None => "wpctl",
};
const PACTL: &str = match option_env!("VOLUME_OSD_PACTL") {
    Some(v) => v,
    None => "pactl",
};

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Volume {
    pub level: f32,
    pub muted: bool,
}

impl Default for Volume {
    fn default() -> Self {
        Self {
            level: 0.0,
            muted: false,
        }
    }
}

impl Volume {
    pub fn changed(self, other: Self) -> bool {
        self.muted != other.muted || (self.level - other.level).abs() > 0.001
    }
}

pub async fn query() -> Option<Volume> {
    let out = Command::new(WPCTL)
        .args(["get-volume", "@DEFAULT_AUDIO_SINK@"])
        .output()
        .await
        .ok()?;
    String::from_utf8_lossy(&out.stdout).parse().ok()
}

#[derive(Debug, PartialEq)]
pub struct ParseVolumeError;

impl FromStr for Volume {
    type Err = ParseVolumeError;

    fn from_str(text: &str) -> Result<Self, Self::Err> {
        Ok(Volume {
            level: text
                .split_whitespace()
                .find_map(|token| token.parse().ok())
                .ok_or(ParseVolumeError)?,
            muted: text.contains("[MUTED]"),
        })
    }
}

pub fn event() -> impl Stream<Item = ()> {
    stream::channel(4, async |mut output| {
        let Ok(mut child) = Command::new(PACTL)
            .arg("subscribe")
            .stdout(Stdio::piped())
            .spawn()
        else {
            return;
        };
        let Some(stdout) = child.stdout.take() else {
            return;
        };
        let mut line = BufReader::new(stdout).lines();
        while let Ok(Some(l)) = line.next_line().await {
            if l.contains("on sink #") || l.contains("on server") {
                let _ = output.send(()).await;
            }
        }
    })
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn unmuted() {
        assert_eq!(
            "Volume: 0.44".parse::<Volume>(),
            Ok(Volume {
                level: 0.44,
                muted: false,
            }),
        );
    }

    #[test]
    fn muted() {
        assert_eq!(
            "Volume: 0.44 [MUTED]".parse::<Volume>(),
            Ok(Volume {
                level: 0.44,
                muted: true,
            }),
        );
    }

    #[test]
    fn above_full() {
        assert_eq!(
            "Volume: 1.50".parse::<Volume>(),
            Ok(Volume {
                level: 1.5,
                muted: false,
            }),
        );
    }

    #[test]
    fn no_level() {
        assert_eq!("Volume:".parse::<Volume>(), Err(ParseVolumeError));
    }
}
