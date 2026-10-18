use std::fs::File;
use std::io::Read;
use std::os::fd::AsRawFd;
use std::os::unix::fs::FileExt;
use std::path::{Path, PathBuf};

use crate::Mode;

pub enum Claim {
    Owner { guard: Guard, recover: bool },
    Signaled,
}

pub struct Guard {
    file: File,
}

impl Guard {
    pub fn mark_recording(&self) -> std::io::Result<()> {
        self.replace(RECORDING)
    }

    fn replace(&self, content: &str) -> std::io::Result<()> {
        self.file.set_len(0)?;
        self.file.write_all_at(content.as_bytes(), 0)
    }
}

impl Drop for Guard {
    fn drop(&mut self) {
        let _ = self.file.set_len(0);
    }
}

const NAME: &str = env!("CARGO_PKG_NAME");
const RECORDING: &str = "recording";

pub fn lock_file() -> PathBuf {
    PathBuf::from(std::env::var_os("XDG_RUNTIME_DIR").unwrap_or_else(|| "/tmp".into()))
        .join(NAME)
        .join("instance.lock")
}

pub fn request_signal(mode: Mode) -> libc::c_int {
    match mode {
        Mode::Screenshot => libc::SIGUSR1,
        Mode::Video => libc::SIGUSR2,
    }
}

fn ignore_request_until_listening() {
    for mode in Mode::ALL {
        unsafe { libc::signal(request_signal(mode), libc::SIG_IGN) };
    }
}

fn whole_file_write_lock() -> libc::flock {
    let mut lock: libc::flock = unsafe { std::mem::zeroed() };
    lock.l_type = libc::F_WRLCK as libc::c_short;
    lock.l_whence = libc::SEEK_SET as libc::c_short;
    lock
}

fn try_lock(file: &File) -> std::io::Result<bool> {
    let lock = whole_file_write_lock();
    if unsafe { libc::fcntl(file.as_raw_fd(), libc::F_SETLK, &lock) } == 0 {
        return Ok(true);
    }
    let error = std::io::Error::last_os_error();
    match error.raw_os_error() {
        Some(libc::EAGAIN | libc::EACCES) => Ok(false),
        _ => Err(error),
    }
}

fn holder(file: &File) -> std::io::Result<Option<libc::pid_t>> {
    let mut lock = whole_file_write_lock();
    if unsafe { libc::fcntl(file.as_raw_fd(), libc::F_GETLK, &mut lock) } == -1 {
        return Err(std::io::Error::last_os_error());
    }
    Ok((lock.l_type != libc::F_UNLCK as libc::c_short).then_some(lock.l_pid))
}

pub fn claim(file: &Path, mode: Mode) -> std::io::Result<Claim> {
    ignore_request_until_listening();
    if let Some(parent) = file.parent() {
        std::fs::create_dir_all(parent)?;
    }
    let mut handle = File::options()
        .read(true)
        .write(true)
        .create(true)
        .truncate(false)
        .open(file)?;
    loop {
        if try_lock(&handle)? {
            let mut previous = String::new();
            handle.read_to_string(&mut previous)?;
            let guard = Guard { file: handle };
            guard.replace("")?;
            return Ok(Claim::Owner {
                guard,
                recover: previous == RECORDING,
            });
        }
        if let Some(pid) = holder(&handle)? {
            unsafe { libc::kill(pid, request_signal(mode)) };
            return Ok(Claim::Signaled);
        }
    }
}

#[cfg(test)]
mod test {
    use super::*;

    fn scratch(name: &str) -> PathBuf {
        let dir = std::env::temp_dir().join(format!(
            "capture-test-instance-{}-{name}",
            std::process::id()
        ));
        let _ = std::fs::remove_dir_all(&dir);
        dir.join("instance.lock")
    }

    fn content(file: &Path) -> String {
        std::fs::read_to_string(file).unwrap()
    }

    fn hold_in_child(file: &Path) -> libc::pid_t {
        std::fs::create_dir_all(file.parent().unwrap()).unwrap();
        let handle = File::options()
            .read(true)
            .write(true)
            .create(true)
            .truncate(false)
            .open(file)
            .unwrap();
        let mut ready = [0; 2];
        assert_eq!(unsafe { libc::pipe(ready.as_mut_ptr()) }, 0);
        match unsafe { libc::fork() } {
            0 => unsafe {
                for mode in Mode::ALL {
                    libc::signal(request_signal(mode), libc::SIG_DFL);
                }
                let _ = try_lock(&handle);
                libc::write(ready[1], [1u8].as_ptr().cast(), 1);
                loop {
                    libc::pause();
                }
            },
            pid => {
                let mut byte = 0u8;
                unsafe { libc::read(ready[0], (&mut byte as *mut u8).cast(), 1) };
                pid
            }
        }
    }

    #[test]
    fn claim_without_file_is_owner() {
        let file = scratch("no-file");
        let claim = claim(&file, Mode::Screenshot).unwrap();
        assert!(matches!(claim, Claim::Owner { recover: false, .. }));
        assert_eq!(content(&file), "");
    }

    #[test]
    fn claim_after_crashed_recording_recovers() {
        let file = scratch("crashed");
        std::fs::create_dir_all(file.parent().unwrap()).unwrap();
        std::fs::write(&file, RECORDING).unwrap();
        let claim = claim(&file, Mode::Video).unwrap();
        assert!(matches!(claim, Claim::Owner { recover: true, .. }));
        assert_eq!(content(&file), "");
    }

    #[test]
    fn guard_drop_clears_recording_mark() {
        let file = scratch("mark");
        let Claim::Owner { guard, .. } = claim(&file, Mode::Video).unwrap() else {
            panic!("expected owner");
        };
        guard.mark_recording().unwrap();
        assert_eq!(content(&file), RECORDING);
        drop(guard);
        assert_eq!(content(&file), "");
        assert!(file.exists());
    }

    #[test]
    fn claim_sends_mode_request_to_holder() {
        for mode in Mode::ALL {
            let file = scratch(mode.name());
            let pid = hold_in_child(&file);
            assert!(matches!(claim(&file, mode).unwrap(), Claim::Signaled));
            let mut status = 0;
            unsafe { libc::waitpid(pid, &mut status, 0) };
            assert!(libc::WIFSIGNALED(status));
            assert_eq!(libc::WTERMSIG(status), request_signal(mode));
        }
    }

    #[test]
    fn request_signal_differs_per_mode() {
        assert_ne!(
            request_signal(Mode::Screenshot),
            request_signal(Mode::Video)
        );
    }

    #[test]
    fn lock_file_in_runtime_dir() {
        assert!(lock_file().ends_with("capture/instance.lock"));
    }
}
