import errno
from pathlib import Path
from typing import Never

import pytest
from keyheat import daemon
from keyheat.resolve import Keymap


class FakeDevice:
	def __init__(self, path: str, name: str) -> None:
		self.path = path
		self.name = name
		self.closed = False

	def close(self) -> None:
		self.closed = True


def raise_enodev() -> Never:
	raise OSError(errno.ENODEV, "No such device")


def test_find_device_skips_vanished_and_matches_name(
	monkeypatch: pytest.MonkeyPatch,
) -> None:
	devices = {
		"/dev/input/event3": "swhkd virtual output",
		"/dev/input/event9": "swhkd tap",
	}
	opened = []

	def open_device(path: str) -> FakeDevice:
		if path not in devices:
			raise_enodev()
		device = FakeDevice(path, devices[path])
		opened.append(device)
		return device

	monkeypatch.setattr(daemon, "open_device", open_device)
	found = daemon.find_device(
		"swhkd tap",
		lambda: ["/dev/input/event1", "/dev/input/event3", "/dev/input/event9"],
	)
	assert found is not None
	assert found.path == "/dev/input/event9"
	assert [device.closed for device in opened] == [True, False]
	assert daemon.find_device("swhkd tap", lambda: ["/dev/input/event3"]) is None


def test_parse_args_builds_config() -> None:
	config = daemon.parse_args(
		[
			"--host",
			"work",
			"--user",
			"alexandre",
			"--state-dir",
			"/var/lib/keyheat",
			"--pause-file",
			"/run/keyheat/paused",
			"--tap-name",
			"swhkd tap",
			"--ignored-chord",
			"ctrl+super+k",
			"--rules",
			"evdev",
			"--model",
			"pc105",
			"--layout",
			"fr",
			"--variant",
			"us",
			"--options",
			"caps:backspace",
			"--xkb-dir",
			"/nix/store/xkb",
		]
	)
	assert config.state_file == Path("/var/lib/keyheat/work.json")
	assert config.pause_file == Path("/run/keyheat/paused")
	assert config.keymap == Keymap(
		"evdev", "pc105", "fr", "us", "caps:backspace", "/nix/store/xkb"
	)
	assert config.ignored_chord == "ctrl+super+k"


class GrabbableDevice(FakeDevice):
	def __init__(self, path: str, name: str, grab_error: OSError | None = None) -> None:
		super().__init__(path, name)
		self.grabbed = False
		self.grab_error = grab_error

	def grab(self) -> None:
		if self.grab_error:
			raise self.grab_error
		self.grabbed = True


def test_open_tap_grabs_device(monkeypatch: pytest.MonkeyPatch) -> None:
	device = GrabbableDevice("/dev/input/event9", "swhkd tap")
	monkeypatch.setattr(daemon, "find_device", lambda _name: device)
	assert daemon.open_tap("swhkd tap") is device
	assert device.grabbed


def test_open_tap_gives_up_when_grab_fails(monkeypatch: pytest.MonkeyPatch) -> None:
	device = GrabbableDevice(
		"/dev/input/event9", "swhkd tap", OSError(errno.EBUSY, "busy")
	)
	monkeypatch.setattr(daemon, "find_device", lambda _name: device)
	assert daemon.open_tap("swhkd tap") is None
	assert device.closed
