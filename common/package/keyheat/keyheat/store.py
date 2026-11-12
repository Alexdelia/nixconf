import json
import os
from pathlib import Path

from keyheat.counts import Counts

STATE_FILE_MODE = 0o640


class StateFileError(Exception):
	pass


def load(path: Path) -> Counts:
	try:
		text = path.read_text(encoding="utf-8")
	except FileNotFoundError:
		return Counts()
	try:
		return Counts.from_json(json.loads(text))
	except (ValueError, KeyError, TypeError, AttributeError) as error:
		raise StateFileError(f"state file unreadable: {path}") from error


def save(path: Path, data: dict) -> None:
	temporary = path.with_suffix(".json.tmp")
	descriptor = os.open(
		temporary, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, STATE_FILE_MODE
	)
	with os.fdopen(descriptor, "w", encoding="utf-8") as file:
		json.dump(data, file, ensure_ascii=False)
		file.flush()
		os.fsync(file.fileno())
	temporary.chmod(STATE_FILE_MODE)
	temporary.replace(path)


class FlushPolicy:
	def __init__(
		self,
		started_at: float,
		min_tokens: int = 2000,
		interval_seconds: float = 3600,
	) -> None:
		self.min_tokens = min_tokens
		self.interval_seconds = interval_seconds
		self._last_flush = started_at

	def due(self, now: float, tokens: int) -> bool:
		return (
			tokens >= self.min_tokens
			and now - self._last_flush >= self.interval_seconds
		)

	def flushed(self, now: float) -> None:
		self._last_flush = now

	def due_on_exit(self, tokens: int) -> bool:
		return tokens >= self.min_tokens
