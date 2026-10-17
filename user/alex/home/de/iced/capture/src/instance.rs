use std::path::{Path, PathBuf};

pub enum Claim {
    Owner(Guard),
    Signaled,
}

pub struct Guard {
    file: PathBuf,
}

impl Drop for Guard {
    fn drop(&mut self) {
        let _ = std::fs::remove_file(&self.file);
    }
}

const NAME: &str = env!("CARGO_PKG_NAME");

pub fn video_pid_file() -> PathBuf {
    PathBuf::from(std::env::var_os("XDG_RUNTIME_DIR").unwrap_or_else(|| "/tmp".into()))
        .join(NAME)
        .join("video.pid")
}

fn is_capture(pid: i32) -> bool {
    std::fs::read_to_string(format!("/proc/{pid}/comm")).is_ok_and(|comm| comm.trim_end() == NAME)
}

fn alive(pid: i32) -> bool {
    unsafe { libc::kill(pid, 0) == 0 }
}

pub fn claim(file: &Path) -> std::io::Result<Claim> {
    claim_with(file, is_capture)
}

fn claim_with(file: &Path, is_capture: impl Fn(i32) -> bool) -> std::io::Result<Claim> {
    let running = std::fs::read_to_string(file)
        .ok()
        .and_then(|content| content.trim().parse::<i32>().ok())
        .filter(|&pid| pid != std::process::id() as i32 && alive(pid) && is_capture(pid));

    if let Some(pid) = running {
        unsafe { libc::kill(pid, libc::SIGINT) };
        return Ok(Claim::Signaled);
    }

    if let Some(parent) = file.parent() {
        std::fs::create_dir_all(parent)?;
    }
    std::fs::write(file, std::process::id().to_string())?;
    Ok(Claim::Owner(Guard {
        file: file.to_owned(),
    }))
}

#[cfg(test)]
mod test {
    use std::os::unix::process::ExitStatusExt;
    use std::process::Command;

    use super::*;

    fn scratch(name: &str) -> PathBuf {
        let dir = std::env::temp_dir().join(format!(
            "capture-test-instance-{}-{name}",
            std::process::id()
        ));
        let _ = std::fs::remove_dir_all(&dir);
        dir.join("video.pid")
    }

    fn write_pid(file: &Path, pid: u32) {
        std::fs::create_dir_all(file.parent().unwrap()).unwrap();
        std::fs::write(file, pid.to_string()).unwrap();
    }

    fn content(file: &Path) -> String {
        std::fs::read_to_string(file).unwrap()
    }

    #[test]
    fn claim_without_file_is_owner() {
        let file = scratch("no-file");
        let claim = claim_with(&file, |_| true).unwrap();
        assert!(matches!(claim, Claim::Owner(_)));
        assert_eq!(content(&file), std::process::id().to_string());
    }

    #[test]
    fn claim_ignores_stale_pid() {
        let file = scratch("stale");
        let mut child = Command::new("true").spawn().unwrap();
        let pid = child.id();
        child.wait().unwrap();
        write_pid(&file, pid);
        let claim = claim_with(&file, |_| true).unwrap();
        assert!(matches!(claim, Claim::Owner(_)));
        assert_eq!(content(&file), std::process::id().to_string());
    }

    #[test]
    fn claim_ignores_foreign_process() {
        let file = scratch("foreign");
        write_pid(&file, std::process::id());
        assert!(matches!(
            claim_with(&file, |_| false).unwrap(),
            Claim::Owner(_)
        ));
    }

    #[test]
    fn claim_signals_live_capture() {
        let file = scratch("live");
        let mut child = Command::new("sleep").arg("30").spawn().unwrap();
        write_pid(&file, child.id());
        assert!(matches!(
            claim_with(&file, |_| true).unwrap(),
            Claim::Signaled
        ));
        assert_eq!(child.wait().unwrap().signal(), Some(libc::SIGINT));
    }

    #[test]
    fn guard_drop_removes_file() {
        let file = scratch("drop");
        let claim = claim_with(&file, |_| true).unwrap();
        assert!(file.exists());
        drop(claim);
        assert!(!file.exists());
    }

    #[test]
    fn video_pid_file_in_runtime_dir() {
        assert!(video_pid_file().ends_with("capture/video.pid"));
    }
}
