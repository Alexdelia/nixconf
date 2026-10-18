use std::os::unix::fs::{DirBuilderExt, MetadataExt, PermissionsExt};
use std::os::unix::process::CommandExt;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::time::{SystemTime, UNIX_EPOCH};

use crate::{geometry::Rect, mute::Mute, tool};

pub const FRAMERATE: u32 = 60;
pub const CRF: u32 = 23;
pub const KEEP: usize = 5;

const EXTENSION: &str = "mp4";
const MIN_SIDE: i32 = 2;
const YUV420_EVEN_CROP: &str = "crop=trunc(iw/2)*2:trunc(ih/2)*2";

pub fn dir() -> PathBuf {
    let uid = unsafe { libc::getuid() };
    PathBuf::from(format!("/tmp/{}-{uid}", env!("CARGO_PKG_NAME")))
}

fn recording(dir: &Path) -> std::io::Result<Vec<(SystemTime, PathBuf)>> {
    let mut recording = Vec::new();
    for entry in std::fs::read_dir(dir)? {
        let path = entry?.path();
        if path
            .extension()
            .is_some_and(|extension| extension == EXTENSION)
        {
            recording.push((std::fs::metadata(&path)?.modified()?, path));
        }
    }
    recording.sort();
    Ok(recording)
}

fn ensure_owned(dir: &Path, uid: u32) -> std::io::Result<()> {
    let metadata = std::fs::symlink_metadata(dir)?;
    if !metadata.is_dir() || metadata.uid() != uid {
        return Err(std::io::Error::new(
            std::io::ErrorKind::PermissionDenied,
            format!("{} not a directory owned by uid {uid}", dir.display()),
        ));
    }
    Ok(())
}

pub fn prepare(dir: &Path) -> std::io::Result<PathBuf> {
    std::fs::DirBuilder::new()
        .recursive(true)
        .mode(0o700)
        .create(dir)?;
    ensure_owned(dir, unsafe { libc::getuid() })?;
    std::fs::set_permissions(dir, std::fs::Permissions::from_mode(0o700))?;

    let old = recording(dir)?;
    let excess = (old.len() + 1).saturating_sub(KEEP);
    for (_, path) in old.into_iter().take(excess) {
        std::fs::remove_file(path)?;
    }

    let millisecond = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_millis();
    Ok(dir.join(format!("{millisecond}.{EXTENSION}")))
}

pub fn recorder_args(rect: Rect, file: &Path) -> Vec<String> {
    [
        "--no-damage",
        "-g",
        &rect.grim_geometry(),
        "-c",
        "libx264",
        "-p",
        "preset=veryfast",
        "-p",
        &format!("crf={CRF}"),
        "-x",
        "yuv420p",
        "-F",
        YUV420_EVEN_CROP,
        "-r",
        &FRAMERATE.to_string(),
        "-f",
        &file.to_string_lossy(),
    ]
    .map(str::to_owned)
    .to_vec()
}

pub fn uri_list(file: &Path) -> String {
    format!("file://{}\r\n", file.display())
}

pub fn copy_args(file: &Path) -> Vec<String> {
    vec![
        "--type".to_owned(),
        "text/uri-list".to_owned(),
        uri_list(file),
    ]
}

pub fn tie_to_parent(command: &mut Command) -> &mut Command {
    unsafe {
        command.pre_exec(|| {
            if libc::prctl(libc::PR_SET_PDEATHSIG, libc::SIGINT) == -1 {
                return Err(std::io::Error::last_os_error());
            }
            Ok(())
        })
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Phase {
    Running,
    Stopping,
    Reaped,
}

pub struct Recording {
    pid: libc::pid_t,
    file: PathBuf,
    phase: Phase,
    _mute: Mute,
}

impl Recording {
    pub fn start(
        rect: Rect,
    ) -> Result<(Recording, impl Future<Output = Result<(), String>> + use<>), String> {
        if rect.width < MIN_SIDE || rect.height < MIN_SIDE {
            return Err("selection too small".to_owned());
        }
        let file = prepare(&dir()).map_err(|error| format!("video dir: {error}"))?;
        let mute = Mute::start();
        let mut child = tie_to_parent(&mut Command::new(tool::wf_recorder()))
            .args(recorder_args(rect, &file))
            .stdin(Stdio::null())
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn()
            .map_err(|error| format!("wf-recorder: {error}"))?;
        let recording = Recording {
            pid: child.id() as libc::pid_t,
            file,
            phase: Phase::Running,
            _mute: mute,
        };
        let exit = async move {
            tokio::task::spawn_blocking(move || child.wait())
                .await
                .map_err(|error| format!("wf-recorder: {error}"))?
                .map(drop)
                .map_err(|error| format!("wf-recorder: {error}"))
        };
        Ok((recording, exit))
    }

    pub fn phase(&self) -> Phase {
        self.phase
    }

    pub fn file(&self) -> &Path {
        &self.file
    }

    pub fn stop(&mut self) {
        if self.phase == Phase::Running {
            unsafe { libc::kill(self.pid, libc::SIGINT) };
            self.phase = Phase::Stopping;
        }
    }

    pub fn kill(&self) {
        if self.phase == Phase::Stopping {
            unsafe { libc::kill(self.pid, libc::SIGKILL) };
        }
    }

    pub fn reaped(&mut self) {
        self.phase = Phase::Reaped;
    }
}

pub async fn deliver(file: PathBuf) -> Result<(), String> {
    let size = tokio::fs::metadata(&file)
        .await
        .map_or(0, |metadata| metadata.len());
    if size == 0 {
        return Err("recorder produced no video".to_owned());
    }
    let copied = tokio::process::Command::new(tool::clipboard_copy())
        .args(copy_args(&file))
        .status()
        .await
        .map_err(|error| format!("clipboard: {error}"))?;
    if !copied.success() {
        return Err(format!("clipboard: {copied}"));
    }
    Ok(())
}

#[cfg(test)]
mod test {
    use std::time::Duration;

    use super::*;

    fn scratch(name: &str) -> PathBuf {
        let dir =
            std::env::temp_dir().join(format!("capture-test-video-{}-{name}", std::process::id()));
        let _ = std::fs::remove_dir_all(&dir);
        dir
    }

    #[test]
    fn tied_child_dies_with_spawning_thread() {
        let mut child = std::thread::spawn(|| {
            tie_to_parent(Command::new("sleep").arg("30"))
                .spawn()
                .unwrap()
        })
        .join()
        .unwrap();
        let deadline = std::time::Instant::now() + Duration::from_secs(2);
        let status = loop {
            if let Some(status) = child.try_wait().unwrap() {
                break Some(status);
            }
            if std::time::Instant::now() > deadline {
                let _ = child.kill();
                break None;
            }
            std::thread::sleep(Duration::from_millis(20));
        };
        use std::os::unix::process::ExitStatusExt;
        assert_eq!(
            status.and_then(|status| status.signal()),
            Some(libc::SIGINT)
        );
    }

    #[test]
    fn recorder_args_exact() {
        let rect = Rect {
            x: 10,
            y: 20,
            width: 300,
            height: 200,
        };
        let args = recorder_args(rect, Path::new("/tmp/x.mp4"));
        assert_eq!(
            args,
            [
                "--no-damage",
                "-g",
                "10,20 300x200",
                "-c",
                "libx264",
                "-p",
                "preset=veryfast",
                "-p",
                "crf=23",
                "-x",
                "yuv420p",
                "-F",
                "crop=trunc(iw/2)*2:trunc(ih/2)*2",
                "-r",
                "60",
                "-f",
                "/tmp/x.mp4"
            ]
        );
        assert!(!args.iter().any(|arg| arg == "-a"));
    }

    #[test]
    fn copy_args_offer_uri_list() {
        assert_eq!(
            copy_args(Path::new("/tmp/capture-1000/a.mp4")),
            [
                "--type",
                "text/uri-list",
                "file:///tmp/capture-1000/a.mp4\r\n"
            ]
        );
    }

    #[test]
    fn uri_list_format() {
        assert_eq!(
            uri_list(Path::new("/tmp/capture-1000/a.mp4")),
            "file:///tmp/capture-1000/a.mp4\r\n"
        );
    }

    #[test]
    fn dir_is_per_user_in_tmp() {
        let uid = unsafe { libc::getuid() };
        assert_eq!(dir(), PathBuf::from(format!("/tmp/capture-{uid}")));
    }

    #[test]
    fn prepare_keeps_last() {
        let dir = scratch("keep");
        std::fs::create_dir_all(&dir).unwrap();
        let base = SystemTime::now() - Duration::from_secs(3600);
        for index in 0..6u64 {
            let file = dir.join(format!("old-{index}.mp4"));
            std::fs::write(&file, "").unwrap();
            std::fs::File::options()
                .write(true)
                .open(&file)
                .unwrap()
                .set_modified(base + Duration::from_secs(index))
                .unwrap();
        }
        std::fs::write(dir.join("note.txt"), "").unwrap();

        let new = prepare(&dir).unwrap();

        let mut remaining: Vec<String> = std::fs::read_dir(&dir)
            .unwrap()
            .map(|entry| entry.unwrap().file_name().into_string().unwrap())
            .filter(|name| name.ends_with(".mp4"))
            .collect();
        remaining.sort();
        assert_eq!(
            remaining,
            ["old-2.mp4", "old-3.mp4", "old-4.mp4", "old-5.mp4"]
        );
        assert!(dir.join("note.txt").exists());
        assert_eq!(new.parent().unwrap(), dir);
        assert_eq!(new.extension().unwrap(), "mp4");
        assert!(!new.exists());
    }

    #[test]
    fn ensure_owned_accepts_own_dir() {
        let dir = scratch("owned");
        std::fs::create_dir_all(&dir).unwrap();
        assert!(ensure_owned(&dir, unsafe { libc::getuid() }).is_ok());
    }

    #[test]
    fn ensure_owned_rejects_other_uid() {
        let dir = scratch("other-uid");
        std::fs::create_dir_all(&dir).unwrap();
        let other = unsafe { libc::getuid() } + 1;
        assert_eq!(
            ensure_owned(&dir, other).unwrap_err().kind(),
            std::io::ErrorKind::PermissionDenied
        );
    }

    #[test]
    fn prepare_rejects_symlink() {
        let target = scratch("symlink-target");
        std::fs::create_dir_all(&target).unwrap();
        let link = scratch("symlink");
        std::os::unix::fs::symlink(&target, &link).unwrap();
        assert_eq!(
            prepare(&link).unwrap_err().kind(),
            std::io::ErrorKind::PermissionDenied
        );
        let _ = std::fs::remove_file(&link);
    }

    #[test]
    fn prepare_creates_private_dir() {
        let dir = scratch("private");
        prepare(&dir).unwrap();
        let mode = std::fs::metadata(&dir).unwrap().permissions().mode();
        assert_eq!(mode & 0o777, 0o700);
    }
}
