import argparse
import json
import os
import sys
from collections.abc import Iterable
from dataclasses import dataclass
from pathlib import Path

from keyheat.counts import FORMAT_VERSION, TRIGRAM_SEPARATOR
from keyheat.resolve import Keymap, KeyResolver, Token

STATE_DIR = Path("/var/lib/keyheat")
VIEWER_DIR = Path(__file__).parent / "viewer"
XKB_DIR_VARIABLE = "KEYHEAT_XKB_DIR"

KEY_LEFTSHIFT = 42
KEY_RIGHTALT = 100
KEY_BACKSPACE = 14
MAIN_KEY_CODES = (
	*range(1, 55),
	56,
	57,
	58,
	*range(59, 69),
	86,
	87,
	88,
	97,
	100,
	*range(102, 112),
	125,
	126,
	127,
)
LEVELS = (
	("", ()),
	("shift", (KEY_LEFTSHIFT,)),
	("altgr", (KEY_RIGHTALT,)),
	("shift+altgr", (KEY_LEFTSHIFT, KEY_RIGHTALT)),
)
CHORD_PREFIXES = ("ctrl+", "alt+", "shift+", "super+")
LEGACY_TOKEN_KEYS = {"VoidSymbol": KEY_BACKSPACE}
DEAD_LABEL = "dead"
NO_SYMBOL = "NoSymbol"
ALTERNATE_OPTIONS = "lv3:ralt_switch,caps:backspace,custom:no_backspace"

type Stroke = tuple[int, str]


class ViewError(Exception):
	pass


@dataclass(frozen=True)
class Layout:
	id: str
	label: str
	layout: str
	variant: str


ALTERNATE_LAYOUTS = (
	Layout("qwerty", "qwerty (us)", "us", ""),
	Layout("colemak", "colemak", "us", "colemak"),
	Layout("colemak_dh", "colemak-dh", "us", "colemak_dh"),
	Layout("dvorak", "dvorak", "us", "dvorak"),
	Layout("workman", "workman", "us", "workman"),
	Layout("bepo", "bépo", "fr", "bepo"),
	Layout("ergol", "ergo-l", "fr", "ergol"),
)


def alternate_keymap(layout: Layout, include_dir: str | None) -> Keymap:
	return Keymap(
		rules="evdev",
		model="pc105",
		layout=layout.layout,
		variant=layout.variant,
		options=ALTERNATE_OPTIONS,
		include_dir=include_dir,
	)


def stored_keymap_to_keymap(stored: dict, include_dir: str | None) -> Keymap:
	return Keymap(
		rules=stored["rules"],
		model=stored["model"],
		layout=stored["layout"],
		variant=stored.get("variant", ""),
		options=stored.get("options", ""),
		include_dir=include_dir,
	)


def press_level(resolver: KeyResolver, code: int, held: Iterable[int]) -> Token | None:
	held = tuple(held)
	for modifier in held:
		resolver.press(modifier)
	token = resolver.press(code)
	resolver.release(code)
	for modifier in reversed(held):
		resolver.release(modifier)
	return token


class KeyFinder:
	def __init__(self, keymap: Keymap) -> None:
		self._resolver = KeyResolver(keymap)
		self.typed: dict[str, list[Stroke]] = {}
		self.base_labels: dict[str, int] = {}
		self.modifiers: dict[str, int] = {}
		self.labels: dict[int, dict[str, str]] = {}
		dead_strokes = self._scan_levels()
		self._scan_dead_keys(dead_strokes)

	def strokes(self, token_name: str) -> list[Stroke] | None:
		if token_name in self.typed:
			return self.typed[token_name]
		if token_name in LEGACY_TOKEN_KEYS:
			return [(LEGACY_TOKEN_KEYS[token_name], "")]
		chord = split_chord(token_name)
		if chord:
			modifiers, label = chord
			code = self.base_labels.get(label, LEGACY_TOKEN_KEYS.get(label))
			return None if code is None else [(code, modifiers)]
		return None

	def _scan_levels(self) -> list[Stroke]:
		dead_strokes = []
		for level, held in LEVELS:
			for code in MAIN_KEY_CODES:
				self._resolver.reset()
				token = press_level(self._resolver, code, held)
				if token is None:
					dead_strokes.append((code, level))
					self.labels.setdefault(code, {})[level] = DEAD_LABEL
				elif token.kind == "modifier":
					self.modifiers.setdefault(token.name, code)
				elif token.kind in ("glyph", "named"):
					self.typed.setdefault(token.name, [(code, level)])
					if token.name != NO_SYMBOL:
						self.labels.setdefault(code, {})[level] = token.name
					if not level:
						self.base_labels.setdefault(token.name, code)
		return dead_strokes

	def _scan_dead_keys(self, dead_strokes: list[Stroke]) -> None:
		for dead_code, dead_level in dead_strokes:
			dead_held = dict(LEVELS)[dead_level]
			for level, held in LEVELS:
				for code in MAIN_KEY_CODES:
					self._resolver.reset()
					press_level(self._resolver, dead_code, dead_held)
					token = press_level(self._resolver, code, held)
					if token is not None and token.kind == "glyph":
						self.typed.setdefault(
							token.name, [(dead_code, dead_level), (code, level)]
						)


def split_chord(token_name: str) -> tuple[str, str] | None:
	modifiers = []
	rest = token_name
	while prefix := next(
		(
			prefix
			for prefix in CHORD_PREFIXES
			if rest.startswith(prefix) and len(rest) > len(prefix)
		),
		None,
	):
		modifiers.append(prefix.removesuffix("+"))
		rest = rest.removeprefix(prefix)
	if not modifiers:
		return None
	return "+".join(modifiers), rest


def key_map(finder: KeyFinder, tokens: Iterable[str]) -> dict[str, list[Stroke]]:
	return {
		token: strokes
		for token in tokens
		if (strokes := finder.strokes(token)) is not None
	}


def load_host(path: Path) -> dict:
	try:
		data = json.loads(path.read_text(encoding="utf-8"))
	except (OSError, ValueError) as error:
		raise ViewError(f"{path}: {error}") from error
	if not isinstance(data, dict) or data.get("version") != FORMAT_VERSION:
		raise ViewError(f"{path}: not a keyheat v{FORMAT_VERSION} file")
	for field in ("host", "keymap", "unigram", "modifier", "trigram"):
		if field not in data:
			raise ViewError(f"{path}: missing {field}")
	return data


def host_payload(data: dict, include_dir: str | None) -> dict:
	tokens = list(data["unigram"])
	native = KeyFinder(stored_keymap_to_keymap(data["keymap"], include_dir))
	layouts = {"native": key_map(native, tokens)}
	labels = {"native": native.labels}
	for layout in ALTERNATE_LAYOUTS:
		finder = KeyFinder(alternate_keymap(layout, include_dir))
		layouts[layout.id] = key_map(finder, tokens)
		labels[layout.id] = finder.labels
	return {
		"name": data["host"],
		"keymap": data["keymap"],
		"unigram": data["unigram"],
		"modifier": data["modifier"],
		"modifierKeys": native.modifiers,
		"trigram": [
			[*key.split(TRIGRAM_SEPARATOR), count]
			for key, count in data["trigram"].items()
		],
		"layouts": layouts,
		"labels": labels,
	}


def build_payload(hosts: list[dict], include_dir: str | None) -> dict:
	names = [host["host"] for host in hosts]
	duplicates = sorted({name for name in names if names.count(name) > 1})
	if duplicates:
		raise ViewError(f"duplicate host: {', '.join(duplicates)}")
	return {
		"hosts": [host_payload(host, include_dir) for host in hosts],
		"layouts": [
			{"id": "native", "label": "host keymap"},
			*({"id": layout.id, "label": layout.label} for layout in ALTERNATE_LAYOUTS),
		],
	}


def embedded_json(payload: dict) -> str:
	return (
		json.dumps(payload, ensure_ascii=True, separators=(",", ":"))
		.replace("<", "\\u003c")
		.replace(">", "\\u003e")
		.replace("&", "\\u0026")
	)


def render_html(payload: dict) -> str:
	template = (VIEWER_DIR / "index.html").read_text(encoding="utf-8")
	replacements = {
		"{{style}}": (VIEWER_DIR / "style.css").read_text(encoding="utf-8"),
		"{{model}}": (VIEWER_DIR / "model.js").read_text(encoding="utf-8"),
		"{{app}}": (VIEWER_DIR / "app.js").read_text(encoding="utf-8"),
		"{{data}}": embedded_json(payload),
	}
	for marker, content in replacements.items():
		template = template.replace(marker, content)
	return template


def write_private(path: Path, content: str) -> None:
	descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
	os.fchmod(descriptor, 0o600)
	with os.fdopen(descriptor, "w", encoding="utf-8") as file:
		file.write(content)


def parse_args(argv: list[str]) -> argparse.Namespace:
	parser = argparse.ArgumentParser(
		prog="keyheat-view", description="write a local html viewer of keyheat data"
	)
	parser.add_argument("files", nargs="*", type=Path)
	parser.add_argument("--output", "-o", type=Path, default=Path("keyheat.html"))
	parser.add_argument("--xkb-dir", default=os.environ.get(XKB_DIR_VARIABLE))
	return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> None:
	arguments = parse_args(sys.argv[1:] if argv is None else argv)
	files = arguments.files or sorted(STATE_DIR.glob("*.json"))
	if not files:
		raise SystemExit(f"no state file given and none in {STATE_DIR}")
	try:
		payload = build_payload([load_host(path) for path in files], arguments.xkb_dir)
	except ViewError as error:
		raise SystemExit(str(error)) from None
	write_private(arguments.output, render_html(payload))
	print(arguments.output.resolve())


if __name__ == "__main__":
	main()
