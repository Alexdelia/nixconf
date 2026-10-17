mod canvas;
mod geometry;
mod instance;
mod memory;
mod mute;
mod output;
mod overlay;
mod screenshot;
mod selection;
mod tool;
mod video;

use instance::Claim;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Mode {
    Screenshot,
    Video,
}

impl Mode {
    pub fn name(self) -> &'static str {
        match self {
            Mode::Screenshot => "screenshot",
            Mode::Video => "video",
        }
    }

    fn parse(argument: &str) -> Option<Mode> {
        [Mode::Screenshot, Mode::Video]
            .into_iter()
            .find(|mode| mode.name() == argument)
    }
}

const EX_USAGE: i32 = 64;

fn main() {
    let program = env!("CARGO_PKG_NAME");
    let Some(mode) = std::env::args().nth(1).as_deref().and_then(Mode::parse) else {
        eprintln!("usage: {program} <screenshot|video>");
        std::process::exit(EX_USAGE);
    };

    if std::env::var_os("SWAYSOCK").is_none() {
        tool::fail("capture: compositor unsupported");
    }

    let guard = match mode {
        Mode::Screenshot => None,
        Mode::Video => match instance::claim(&instance::video_pid_file()) {
            Ok(Claim::Signaled) => return,
            Ok(Claim::Owner { guard, stale }) => {
                if stale {
                    mute::recover();
                }
                Some(guard)
            }
            Err(error) => tool::fail(&format!("capture: pid file: {error}")),
        },
    };

    let outputs = output::query().unwrap_or_else(|error| tool::fail(&format!("capture: {error}")));
    let saved = memory::load(&memory::path(mode), &outputs);

    if let Err(error) = overlay::run(mode, outputs, saved, guard) {
        tool::fail(&format!("capture: {error}"));
    }
}
