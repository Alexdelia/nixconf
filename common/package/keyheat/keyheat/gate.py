from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path

from jeepney import DBusAddress, Properties, new_method_call
from jeepney.io.blocking import open_dbus_connection

LOCKER_COMMS = frozenset({"swaylock", "kscreenlocker_g"})
GRAPHICAL_SESSION_TYPES = frozenset({"wayland", "x11"})
PHYSICAL_SEAT = "seat0"
LOGIND_BUS_NAME = "org.freedesktop.login1"
LOGIND_MANAGER = DBusAddress(
	"/org/freedesktop/login1",
	bus_name=LOGIND_BUS_NAME,
	interface="org.freedesktop.login1.Manager",
)
PROC = Path("/proc")
DBUS_TIMEOUT_SECONDS = 2


@dataclass(frozen=True)
class Session:
	user: str
	seat: str
	type: str
	active: bool
	locked: bool


class Gate:
	def __init__(
		self,
		user: str,
		pause_file: Path,
		sessions: Callable[[], list[Session]],
		process_names: Callable[[], set[str]],
	) -> None:
		self._user = user
		self._pause_file = pause_file
		self._sessions = sessions
		self._process_names = process_names

	def paused(self) -> bool:
		return self._pause_file.exists()

	def allowed(self) -> bool:
		if self.paused():
			return False
		if self._process_names() & LOCKER_COMMS:
			return False
		return any(self._is_usable(session) for session in self._sessions())

	def _is_usable(self, session: Session) -> bool:
		return (
			session.user == self._user
			and session.seat == PHYSICAL_SEAT
			and session.type in GRAPHICAL_SESSION_TYPES
			and session.active
			and not session.locked
		)


def logind_sessions() -> list[Session]:
	with open_dbus_connection(bus="SYSTEM") as connection:
		listing = connection.send_and_get_reply(
			new_method_call(LOGIND_MANAGER, "ListSessions"),
			timeout=DBUS_TIMEOUT_SECONDS,
		).body[0]
		sessions = []
		for entry in listing:
			user, seat, object_path = entry[2], entry[3], entry[4]
			address = DBusAddress(
				object_path,
				bus_name=LOGIND_BUS_NAME,
				interface="org.freedesktop.login1.Session",
			)
			properties = connection.send_and_get_reply(
				Properties(address).get_all(), timeout=DBUS_TIMEOUT_SECONDS
			).body[0]
			sessions.append(
				Session(
					user=user,
					seat=seat,
					type=properties["Type"][1],
					active=properties["Active"][1],
					locked=properties["LockedHint"][1],
				)
			)
		return sessions


def running_process_names(proc_root: Path = PROC) -> set[str]:
	names = set()
	for entry in proc_root.iterdir():
		if not entry.name.isdigit():
			continue
		try:
			names.add((entry / "comm").read_text().strip())
			argv0 = (entry / "cmdline").read_bytes().split(b"\0", 1)[0]
		except (FileNotFoundError, ProcessLookupError, PermissionError):
			continue
		if argv0:
			names.add(Path(argv0.decode(errors="replace")).name)
	return names
