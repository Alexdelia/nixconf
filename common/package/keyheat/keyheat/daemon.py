import argparse
import asyncio
import logging
import signal
import time
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path

import evdev
from evdev import ecodes
from jeepney import DBusErrorResponse
from keyheat.counts import Counts
from keyheat.gate import Gate, logind_sessions, running_process_names
from keyheat.recorder import KEY_PRESS, Recorder
from keyheat.resolve import Keymap, KeyResolver
from keyheat.store import FlushPolicy, save

TAP_RETRY_SECONDS = 2
POINTER_RESCAN_SECONDS = 5
GATE_POLL_SECONDS = 1
FLUSH_CHECK_SECONDS = 60
POINTER_BUTTONS = frozenset({ecodes.BTN_LEFT, ecodes.BTN_TOUCH})
SWHKD_DEVICE_NAMES = frozenset({"swhkd tap", "swhkd virtual output"})
GATE_FAILURES = (OSError, TimeoutError, KeyError, DBusErrorResponse)

log = logging.getLogger("keyheat")


@dataclass(frozen=True)
class DaemonConfig:
	host: str
	user: str
	state_file: Path
	pause_file: Path
	tap_name: str
	ignored_chord: str
	keymap: Keymap


def parse_args(argv: list[str]) -> DaemonConfig:
	parser = argparse.ArgumentParser(prog="keyheat")
	for name in (
		"host",
		"user",
		"state-dir",
		"pause-file",
		"tap-name",
		"ignored-chord",
		"rules",
		"model",
		"layout",
		"options",
		"xkb-dir",
	):
		parser.add_argument(f"--{name}", required=True)
	parser.add_argument("--variant", default="")
	arguments = parser.parse_args(argv)
	return DaemonConfig(
		host=arguments.host,
		user=arguments.user,
		state_file=Path(arguments.state_dir) / f"{arguments.host}.json",
		pause_file=Path(arguments.pause_file),
		tap_name=arguments.tap_name,
		ignored_chord=arguments.ignored_chord,
		keymap=Keymap(
			rules=arguments.rules,
			model=arguments.model,
			layout=arguments.layout,
			variant=arguments.variant,
			options=arguments.options,
			include_dir=arguments.xkb_dir,
		),
	)


def open_device(path: str) -> evdev.InputDevice:
	return evdev.InputDevice(path)


def find_device(
	name: str, list_paths: Callable[[], list[str]] = evdev.list_devices
) -> evdev.InputDevice | None:
	for path in list_paths():
		try:
			device = open_device(path)
		except OSError:
			continue
		if device.name == name:
			return device
		device.close()
	return None


def open_tap(name: str) -> evdev.InputDevice | None:
	device = find_device(name)
	if device is None:
		return None
	try:
		device.grab()
	except OSError:
		device.close()
		return None
	return device


def is_pointer(device: evdev.InputDevice) -> bool:
	if device.name in SWHKD_DEVICE_NAMES:
		return False
	keys = device.capabilities().get(ecodes.EV_KEY, [])
	return not POINTER_BUTTONS.isdisjoint(keys)


class Daemon:
	def __init__(
		self,
		config: DaemonConfig,
		counts: Counts,
		clock: Callable[[], float] = time.monotonic,
	) -> None:
		self._config = config
		self._clock = clock
		self._recorder = Recorder(
			KeyResolver(config.keymap), counts, config.ignored_chord
		)
		self._gate = Gate(
			config.user, config.pause_file, logind_sessions, running_process_names
		)
		self._policy = FlushPolicy(started_at=clock())
		self._counting = False
		self._gate_failing = False
		self._pointer_paths: set[str] = set()
		self._stop = asyncio.Event()

	@property
	def counts(self) -> Counts:
		return self._recorder.counts

	async def run(self) -> None:
		loop = asyncio.get_running_loop()
		for signal_number in (signal.SIGTERM, signal.SIGINT):
			loop.add_signal_handler(signal_number, self._stop.set)
		log.info("started")
		async with asyncio.TaskGroup() as group:
			workers = [
				group.create_task(self._read_tap()),
				group.create_task(self._watch_pointers(group)),
				group.create_task(self._watch_gate()),
				group.create_task(self._flush_periodically()),
			]
			await self._stop.wait()
			for worker in workers:
				worker.cancel()
			for task in asyncio.all_tasks():
				if task.get_name().startswith("pointer:"):
					task.cancel()
		self._flush_on_exit()
		log.info("stopped")

	async def _read_tap(self) -> None:
		while True:
			device = open_tap(self._config.tap_name)
			if device is None:
				await asyncio.sleep(TAP_RETRY_SECONDS)
				continue
			log.info("tap device opened")
			self._recorder.on_resync(device.active_keys())
			try:
				async for event in device.async_read_loop():
					if event.type == ecodes.EV_KEY:
						self._recorder.on_key(
							event.code,
							event.value,
							self._clock(),
							self._counting and not self._gate.paused(),
						)
					elif (
						event.type == ecodes.EV_SYN and event.code == ecodes.SYN_DROPPED
					):
						self._recorder.on_resync(device.active_keys())
			except OSError:
				log.warning("tap device lost")
				self.counts.break_sequence()
			finally:
				device.close()
			await asyncio.sleep(TAP_RETRY_SECONDS)

	async def _watch_pointers(self, group: asyncio.TaskGroup) -> None:
		while True:
			for path in evdev.list_devices():
				if path in self._pointer_paths:
					continue
				try:
					device = open_device(path)
				except OSError:
					continue
				if not is_pointer(device):
					device.close()
					continue
				self._pointer_paths.add(path)
				group.create_task(self._read_pointer(device), name=f"pointer:{path}")
			await asyncio.sleep(POINTER_RESCAN_SECONDS)

	async def _read_pointer(self, device: evdev.InputDevice) -> None:
		try:
			async for event in device.async_read_loop():
				if event.type == ecodes.EV_KEY and event.value == KEY_PRESS:
					self._recorder.on_pointer()
		except OSError:
			pass
		finally:
			self._pointer_paths.discard(device.path)
			device.close()

	async def _watch_gate(self) -> None:
		while True:
			allowed = await asyncio.to_thread(self._gate_allows)
			if allowed != self._counting:
				self._counting = allowed
				self._recorder.on_gate_change()
				log.info("resumed" if allowed else "paused")
			await asyncio.sleep(GATE_POLL_SECONDS)

	def _gate_allows(self) -> bool:
		try:
			allowed = self._gate.allowed()
		except GATE_FAILURES as error:
			if not self._gate_failing:
				log.warning("gate check failed: %s", type(error).__name__)
			self._gate_failing = True
			return False
		self._gate_failing = False
		return allowed

	async def _flush_periodically(self) -> None:
		while True:
			await asyncio.sleep(FLUSH_CHECK_SECONDS)
			now = self._clock()
			if self._policy.due(now, self.counts.tokens_since_flush):
				self._save()
				self._policy.flushed(now)

	def _flush_on_exit(self) -> None:
		self.counts.break_sequence()
		if self._policy.due_on_exit(self.counts.tokens_since_flush):
			self._save()

	def _save(self) -> None:
		save(
			self._config.state_file,
			self.counts.to_json(self._config.host, self._config.keymap),
		)
		self.counts.mark_flushed()
		log.info("flushed")
