from dataclasses import dataclass
from typing import Literal

from xkbcommon import xkb

EVDEV_TO_XKB_OFFSET = 8
COMPOSE_LOCALE = "C.UTF-8"
DEAD_KEYSYM_PREFIX = "dead_"

MODIFIER_KEYSYMS = frozenset(
	{
		"Shift_L",
		"Shift_R",
		"Control_L",
		"Control_R",
		"Alt_L",
		"Alt_R",
		"Super_L",
		"Super_R",
		"ISO_Level3_Shift",
	}
)

CHORD_MODIFIER_ORDER = ("ctrl", "alt", "shift", "super")
CHORD_TRIGGERS = ("ctrl", "alt", "super")
XKB_MODIFIER_NAMES = {
	"ctrl": "Control",
	"alt": "Mod1",
	"shift": "Shift",
	"super": "Mod4",
}

COMPOSE_COMPOSING = 1
COMPOSE_COMPOSED = 2


@dataclass(frozen=True)
class Keymap:
	rules: str
	model: str
	layout: str
	variant: str
	options: str
	include_dir: str | None = None


@dataclass(frozen=True)
class Token:
	kind: Literal["glyph", "chord", "named", "modifier"]
	name: str


def is_printable(text: str) -> bool:
	return bool(text) and text.isprintable()


class KeyResolver:
	def __init__(self, keymap: Keymap) -> None:
		self._context = xkb.Context(no_default_includes=True)
		if keymap.include_dir:
			self._context.include_path_append(keymap.include_dir)
		self._context.include_path_append_default()
		self._keymap = self._context.keymap_new_from_names(
			rules=keymap.rules,
			model=keymap.model,
			layout=keymap.layout,
			variant=keymap.variant,
			options=keymap.options,
		)
		self._compose = self._context.compose_table_new_from_locale(
			COMPOSE_LOCALE
		).compose_state_new()
		self.reset()

	def reset(self) -> None:
		self._state = self._keymap.state_new()
		self._compose.reset()

	def press(self, code: int) -> Token | None:
		xkb_code = code + EVDEV_TO_XKB_OFFSET
		token = self._resolve(xkb_code)
		self._state.update_key(xkb_code, xkb.KeyDirection.XKB_KEY_DOWN)
		return token

	def release(self, code: int) -> None:
		self._state.update_key(code + EVDEV_TO_XKB_OFFSET, xkb.KeyDirection.XKB_KEY_UP)

	def reset_compose(self) -> None:
		self._compose.reset()

	def _resolve(self, xkb_code: int) -> Token | None:
		base_name = self._base_keysym_name(xkb_code)
		if base_name in MODIFIER_KEYSYMS:
			return Token("modifier", base_name)

		held = [
			name
			for name in CHORD_MODIFIER_ORDER
			if self._state.mod_name_is_active(
				XKB_MODIFIER_NAMES[name], xkb.StateComponent.XKB_STATE_MODS_EFFECTIVE
			)
		]
		if any(name in CHORD_TRIGGERS for name in held):
			self._compose.reset()
			return Token("chord", "+".join([*held, self._base_label(xkb_code)]))

		keysym = self._state.key_get_one_sym(xkb_code)
		if self._compose.get_status() == COMPOSE_COMPOSING or xkb.keysym_get_name(
			keysym
		).startswith(DEAD_KEYSYM_PREFIX):
			self._compose.feed(keysym)
			status = self._compose.get_status()
			if status == COMPOSE_COMPOSING:
				return None
			if status == COMPOSE_COMPOSED:
				composed = self._compose.get_utf8()
				self._compose.reset()
				return Token("glyph", composed)
			self._compose.reset()

		text = self._state.key_get_string(xkb_code)
		if is_printable(text):
			return Token("glyph", text)
		return Token("named", xkb.keysym_get_name(keysym))

	def _base_keysym(self, xkb_code: int) -> int:
		layout = self._state.key_get_layout(xkb_code)
		syms = self._keymap.key_get_syms_by_level(xkb_code, layout, 0)
		return syms[0] if syms else 0

	def _base_keysym_name(self, xkb_code: int) -> str:
		return xkb.keysym_get_name(self._base_keysym(xkb_code))

	def _base_label(self, xkb_code: int) -> str:
		keysym = self._base_keysym(xkb_code)
		text = xkb.keysym_to_string(keysym)
		return text if is_printable(text) else xkb.keysym_get_name(keysym)
