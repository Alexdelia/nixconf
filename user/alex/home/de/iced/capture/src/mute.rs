use std::process::Command;

use serde::Deserialize;

use crate::tool;

#[derive(Deserialize)]
struct Notification {
    id: u64,
}

fn id(json: &str) -> Vec<u64> {
    serde_json::from_str::<Vec<Notification>>(json)
        .unwrap_or_default()
        .into_iter()
        .map(|notification| notification.id)
        .collect()
}

pub fn max_id(json: &[&str]) -> u64 {
    json.iter().flat_map(|json| id(json)).max().unwrap_or(0)
}

pub fn held(history_json: &str, before: u64) -> usize {
    id(history_json)
        .into_iter()
        .filter(|&id| id > before)
        .count()
}

fn makoctl(argument: &[&str]) -> String {
    Command::new(tool::makoctl())
        .args(argument)
        .output()
        .map(|result| String::from_utf8_lossy(&result.stdout).into_owned())
        .unwrap_or_default()
}

pub fn recover() {
    makoctl(&["mode", "-r", tool::mako_mode()]);
}

pub struct Mute {
    before: u64,
}

impl Mute {
    pub fn start() -> Mute {
        let before = max_id(&[&makoctl(&["list", "-j"]), &makoctl(&["history", "-j"])]);
        makoctl(&["mode", "-a", tool::mako_mode()]);
        Mute { before }
    }
}

impl Drop for Mute {
    fn drop(&mut self) {
        makoctl(&["mode", "-r", tool::mako_mode()]);
        for _ in 0..held(&makoctl(&["history", "-j"]), self.before) {
            makoctl(&["restore"]);
        }
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn max_id_over_list_and_history() {
        assert_eq!(max_id(&[r#"[{"id":3}]"#, r#"[{"id":7},{"id":5}]"#]), 7);
        assert_eq!(max_id(&["[]", "[\n]"]), 0);
    }

    #[test]
    fn max_id_ignores_invalid_json() {
        assert_eq!(max_id(&["", r#"[{"id":2}]"#]), 2);
    }

    #[test]
    fn held_counts_newer_only() {
        assert_eq!(held(r#"[{"id":9,"summary":"a"},{"id":8},{"id":4}]"#, 5), 2);
    }
}
