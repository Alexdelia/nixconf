from keyheat.counts import Counts
from keyheat.resolve import KeyResolver

KEY_RELEASE = 0
KEY_PRESS = 1
KEY_AUTOREPEAT = 2
BTN_MISC = 0x100


class Recorder:
	def __init__(
		self,
		resolver: KeyResolver,
		counts: Counts,
		ignored_chord: str,
		idle_seconds: float = 5,
	) -> None:
		self.resolver = resolver
		self.counts = counts
		self._ignored_chord = ignored_chord
		self._idle_seconds = idle_seconds
		self._last_press: float | None = None

	def on_key(self, code: int, value: int, now: float, counting: bool) -> None:
		if value == KEY_AUTOREPEAT:
			return
		if code >= BTN_MISC:
			if value == KEY_PRESS:
				self.on_pointer()
			return
		if value == KEY_RELEASE:
			self.resolver.release(code)
			return

		token = self.resolver.press(code)
		if self._is_idle(now):
			self.counts.break_sequence()
		self._last_press = now
		if counting and token is not None and token.name != self._ignored_chord:
			self.counts.add(token)

	def on_pointer(self) -> None:
		self.counts.break_sequence()

	def on_resync(self, active_keys: list[int]) -> None:
		self.counts.break_sequence()
		self.resolver.reset()
		for code in active_keys:
			if code < BTN_MISC:
				self.resolver.press(code)

	def on_gate_change(self) -> None:
		self.counts.break_sequence()
		self.resolver.reset_compose()

	def _is_idle(self, now: float) -> bool:
		return (
			self._last_press is not None and now - self._last_press > self._idle_seconds
		)
