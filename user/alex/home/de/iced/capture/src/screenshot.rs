use std::process::Stdio;

use tokio::process::Command;

use crate::{geometry::Rect, tool};

pub fn grim_argument(rect: Rect) -> Vec<String> {
    ["-c", "-g", &rect.grim_geometry(), "-"]
        .map(str::to_owned)
        .to_vec()
}

pub async fn copy(rect: Rect) -> Result<(), String> {
    let mut grim = Command::new(tool::grim())
        .args(grim_argument(rect))
        .stdout(Stdio::piped())
        .spawn()
        .map_err(|error| format!("grim: {error}"))?;
    let image: Stdio = grim
        .stdout
        .take()
        .ok_or("grim: no stdout")?
        .try_into()
        .map_err(|error| format!("grim: {error}"))?;
    let copied = Command::new(tool::clipboard_copy())
        .args(["--type", "image/png"])
        .stdin(image)
        .status()
        .await
        .map_err(|error| format!("clipboard: {error}"))?;
    let captured = grim
        .wait()
        .await
        .map_err(|error| format!("grim: {error}"))?;
    if !captured.success() {
        return Err(format!("grim: {captured}"));
    }
    if !copied.success() {
        return Err(format!("clipboard: {copied}"));
    }
    Ok(())
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn grim_argument_exact() {
        let rect = Rect {
            x: 10,
            y: 20,
            width: 300,
            height: 200,
        };
        assert_eq!(grim_argument(rect), ["-c", "-g", "10,20 300x200", "-"]);
    }
}
