use std::process::Command;

use serde::Deserialize;

use crate::{geometry::Rect, tool};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Output {
    pub name: String,
    pub rect: Rect,
}

#[derive(Deserialize)]
struct SwayOutput {
    name: String,
    active: bool,
    rect: Rect,
}

pub fn parse(json: &str) -> Vec<Output> {
    serde_json::from_str::<Vec<SwayOutput>>(json)
        .unwrap_or_default()
        .into_iter()
        .filter(|output| output.active)
        .map(|output| Output {
            name: output.name,
            rect: output.rect,
        })
        .collect()
}

pub fn query() -> Result<Vec<Output>, String> {
    let result = Command::new(tool::swaymsg())
        .args(["-r", "-t", "get_outputs"])
        .output()
        .map_err(|error| format!("swaymsg: {error}"))?;
    if !result.status.success() {
        return Err(format!("swaymsg: {}", result.status));
    }
    Ok(parse(&String::from_utf8_lossy(&result.stdout)))
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn parse_skips_inactive() {
        let json = r#"[
            {"name": "DP-1", "active": true, "scale": 1.0,
             "rect": {"x": 0, "y": 0, "width": 2560, "height": 1440}},
            {"name": "HDMI-A-1", "active": false, "scale": 1.0,
             "rect": {"x": 0, "y": 0, "width": 0, "height": 0}}
        ]"#;
        assert_eq!(
            parse(json),
            vec![Output {
                name: "DP-1".to_owned(),
                rect: Rect {
                    x: 0,
                    y: 0,
                    width: 2560,
                    height: 1440
                },
            }]
        );
    }

    #[test]
    fn parse_invalid_json_is_empty() {
        assert_eq!(parse("not json"), vec![]);
    }
}
