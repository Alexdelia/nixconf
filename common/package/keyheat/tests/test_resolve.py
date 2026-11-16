from conftest import type_keys
from keyheat.resolve import KeyResolver, Token


def test_plain_letter(work_resolver: KeyResolver) -> None:
	assert type_keys(work_resolver, 18) == Token("glyph", "e")


def test_shift_digit_gives_dollar(work_resolver: KeyResolver) -> None:
	assert type_keys(work_resolver, 42, 5) == Token("glyph", "$")


def test_altgr_e_gives_eacute_on_both_hosts(
	work_resolver: KeyResolver, jiruo_resolver: KeyResolver
) -> None:
	assert type_keys(work_resolver, 100, 18) == Token("glyph", "é")
	assert type_keys(jiruo_resolver, 100, 18) == Token("glyph", "é")


def test_altgr_4_gives_euro(
	work_resolver: KeyResolver, jiruo_resolver: KeyResolver
) -> None:
	assert type_keys(work_resolver, 100, 5) == Token("glyph", "€")
	assert type_keys(jiruo_resolver, 100, 5) == Token("glyph", "€")


def test_caps_is_backspace_and_backspace_is_less(
	work_resolver: KeyResolver, jiruo_resolver: KeyResolver
) -> None:
	for resolver in (work_resolver, jiruo_resolver):
		assert type_keys(resolver, 58) == Token("named", "BackSpace")
		assert type_keys(resolver, 14) == Token("glyph", "<")


def test_chords(work_resolver: KeyResolver) -> None:
	assert type_keys(work_resolver, 29, 47) == Token("chord", "ctrl+v")
	assert type_keys(work_resolver, 29, 42, 20) == Token("chord", "ctrl+shift+t")
	assert type_keys(work_resolver, 125, 28) == Token("chord", "super+Return")
	assert type_keys(work_resolver, 29, 39) == Token("chord", "ctrl+;")
	assert type_keys(work_resolver, 56, 15) == Token("chord", "alt+Tab")
	assert type_keys(work_resolver, 29, 125, 37) == Token("chord", "ctrl+super+k")


def test_altgr_never_makes_a_chord(jiruo_resolver: KeyResolver) -> None:
	assert type_keys(jiruo_resolver, 100, 46) == Token("glyph", "ç")


def test_space_and_named(work_resolver: KeyResolver) -> None:
	assert type_keys(work_resolver, 57) == Token("glyph", " ")
	assert type_keys(work_resolver, 28) == Token("named", "Return")


def test_modifier_press_is_modifier_token(work_resolver: KeyResolver) -> None:
	assert work_resolver.press(42) == Token("modifier", "Shift_L")
	work_resolver.release(42)
	assert work_resolver.press(100) == Token("modifier", "ISO_Level3_Shift")
	work_resolver.release(100)


def test_dead_circumflex_composes(work_resolver: KeyResolver) -> None:
	assert type_keys(work_resolver, 100, 7) is None
	assert type_keys(work_resolver, 18) == Token("glyph", "ê")


def test_dead_key_cancelled_emits_second_key(work_resolver: KeyResolver) -> None:
	assert type_keys(work_resolver, 100, 7) is None
	assert type_keys(work_resolver, 45) == Token("glyph", "x")
