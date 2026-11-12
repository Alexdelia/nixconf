from collections import Counter
from dataclasses import asdict

from keyheat.resolve import Keymap, Token

FORMAT_VERSION = 1
SEQUENCE_START = "\u0002"
SEQUENCE_END = "\u0003"
TRIGRAM_SEPARATOR = "\u0000"
TRIGRAM_LENGTH = 3


def stored_keymap(keymap: Keymap) -> dict:
	fields = asdict(keymap)
	del fields["include_dir"]
	return fields


class Counts:
	def __init__(self) -> None:
		self.unigram: Counter[str] = Counter()
		self.modifier: Counter[str] = Counter()
		self.trigram: Counter[str] = Counter()
		self.tokens_since_flush = 0
		self.loaded_keymap: dict | None = None
		self._window = [SEQUENCE_START]

	def add(self, token: Token) -> None:
		if token.kind == "modifier":
			self.modifier[token.name] += 1
			return
		self.unigram[token.name] += 1
		self.tokens_since_flush += 1
		self._push(token.name)

	def break_sequence(self) -> None:
		if len(self._window) > 1:
			self._push(SEQUENCE_END)
		self._window = [SEQUENCE_START]

	def mark_flushed(self) -> None:
		self.tokens_since_flush = 0

	def to_json(self, host: str, keymap: Keymap) -> dict:
		return {
			"version": FORMAT_VERSION,
			"host": host,
			"keymap": stored_keymap(keymap),
			"unigram": dict(self.unigram),
			"modifier": dict(self.modifier),
			"trigram": dict(self.trigram),
		}

	@classmethod
	def from_json(cls, data: dict) -> "Counts":
		if data.get("version") != FORMAT_VERSION:
			raise ValueError(f"unsupported state version: {data.get('version')}")
		counts = cls()
		counts.unigram.update(data["unigram"])
		counts.modifier.update(data["modifier"])
		counts.trigram.update(data["trigram"])
		counts.loaded_keymap = data.get("keymap")
		return counts

	def _push(self, name: str) -> None:
		self._window.append(name)
		if len(self._window) >= TRIGRAM_LENGTH:
			self._window = self._window[-TRIGRAM_LENGTH:]
			self.trigram[TRIGRAM_SEPARATOR.join(self._window)] += 1
