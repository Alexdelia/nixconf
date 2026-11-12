from collections.abc import Sequence
from collections.abc import Set as AbstractSet
from pathlib import Path

from keyheat.gate import Gate, Session, running_process_names

ACTIVE_SESSION = Session("alexandre", "seat0", "wayland", active=True, locked=False)


def make_gate(
	tmp_path: Path,
	sessions: Sequence[Session] = (ACTIVE_SESSION,),
	names: AbstractSet[str] = frozenset(),
) -> Gate:
	return Gate(
		"alexandre",
		tmp_path / "paused",
		lambda: list(sessions),
		lambda: set(names),
	)


def test_gate_open_for_active_unlocked_session(tmp_path: Path) -> None:
	assert make_gate(tmp_path).allowed()


def test_gate_open_for_x11_session(tmp_path: Path) -> None:
	session = Session("alexandre", "seat0", "x11", active=True, locked=False)
	assert make_gate(tmp_path, sessions=[session]).allowed()


def test_gate_closed_when_paused(tmp_path: Path) -> None:
	(tmp_path / "paused").touch()
	assert not make_gate(tmp_path).allowed()


def test_gate_closed_when_locker_running(tmp_path: Path) -> None:
	assert not make_gate(tmp_path, names={"swaylock"}).allowed()
	assert not make_gate(tmp_path, names={"kscreenlocker_g"}).allowed()


def test_gate_closed_without_graphical_session(tmp_path: Path) -> None:
	assert not make_gate(tmp_path, sessions=[]).allowed()
	tty = Session("alexandre", "seat0", "tty", active=True, locked=False)
	assert not make_gate(tmp_path, sessions=[tty]).allowed()


def test_gate_closed_when_session_locked_or_inactive(tmp_path: Path) -> None:
	locked = Session("alexandre", "seat0", "wayland", active=True, locked=True)
	inactive = Session("alexandre", "seat0", "wayland", active=False, locked=False)
	assert not make_gate(tmp_path, sessions=[locked]).allowed()
	assert not make_gate(tmp_path, sessions=[inactive]).allowed()


def test_gate_closed_for_other_user_or_seat(tmp_path: Path) -> None:
	greeter = Session("greeter", "seat0", "wayland", active=True, locked=False)
	remote = Session("alexandre", "", "wayland", active=True, locked=False)
	assert not make_gate(tmp_path, sessions=[greeter]).allowed()
	assert not make_gate(tmp_path, sessions=[remote]).allowed()


TASK_COMM_LENGTH = 15
WRAPPED_SWAYLOCK_COMM = ".swaylock-wrapped"[:TASK_COMM_LENGTH]


def write_process(proc_root: Path, pid: int, comm: str, argv0: str) -> None:
	process = proc_root / str(pid)
	process.mkdir()
	(process / "comm").write_text(comm + "\n")
	(process / "cmdline").write_bytes(argv0.encode() + b"\0--flag\0")


def test_process_names_include_argv0_of_wrapped_binaries(tmp_path: Path) -> None:
	write_process(tmp_path, 42, WRAPPED_SWAYLOCK_COMM, "swaylock")
	write_process(tmp_path, 43, "kscreenlocker_g", "/usr/lib/kscreenlocker_greet")
	(tmp_path / "self").mkdir()
	names = running_process_names(tmp_path)
	assert {"swaylock", "kscreenlocker_greet", WRAPPED_SWAYLOCK_COMM} <= names


def test_gate_closed_when_wrapped_swaylock_running(tmp_path: Path) -> None:
	proc_root = tmp_path / "proc"
	proc_root.mkdir()
	write_process(proc_root, 42, WRAPPED_SWAYLOCK_COMM, "swaylock")
	gate = Gate(
		"alexandre",
		tmp_path / "paused",
		lambda: [ACTIVE_SESSION],
		lambda: running_process_names(proc_root),
	)
	assert not gate.allowed()


def test_paused_reflects_pause_file(tmp_path: Path) -> None:
	gate = make_gate(tmp_path)
	assert not gate.paused()
	(tmp_path / "paused").touch()
	assert gate.paused()
