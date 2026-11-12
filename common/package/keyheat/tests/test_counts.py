from collections import Counter

import pytest
from conftest import WORK_KEYMAP, trigram
from keyheat.counts import SEQUENCE_END, SEQUENCE_START, Counts
from keyheat.resolve import Token


def test_two_tokens_give_start_and_end_trigrams() -> None:
	counts = Counts()
	counts.add(Token("glyph", "h"))
	counts.add(Token("glyph", "i"))
	counts.break_sequence()
	assert counts.trigram == Counter(
		{trigram(SEQUENCE_START, "h", "i"): 1, trigram("h", "i", SEQUENCE_END): 1}
	)


def test_long_sequence_slides_window() -> None:
	counts = Counts()
	for letter in "abc":
		counts.add(Token("glyph", letter))
	counts.break_sequence()
	assert counts.trigram == Counter(
		{
			trigram(SEQUENCE_START, "a", "b"): 1,
			trigram("a", "b", "c"): 1,
			trigram("b", "c", SEQUENCE_END): 1,
		}
	)


def test_single_token_sequence() -> None:
	counts = Counts()
	counts.add(Token("named", "Return"))
	counts.break_sequence()
	assert counts.trigram == Counter(
		{trigram(SEQUENCE_START, "Return", SEQUENCE_END): 1}
	)


def test_empty_break_counts_nothing() -> None:
	counts = Counts()
	counts.break_sequence()
	counts.break_sequence()
	assert counts.trigram == Counter()


def test_modifier_counted_outside_sequence() -> None:
	counts = Counts()
	counts.add(Token("glyph", "a"))
	counts.add(Token("modifier", "Shift_L"))
	counts.add(Token("glyph", "B"))
	counts.break_sequence()
	assert counts.modifier == Counter({"Shift_L": 1})
	assert trigram(SEQUENCE_START, "a", "B") in counts.trigram
	assert counts.tokens_since_flush == 2


def test_mark_flushed_resets_token_count() -> None:
	counts = Counts()
	counts.add(Token("glyph", "a"))
	counts.mark_flushed()
	assert counts.tokens_since_flush == 0


def test_json_round_trip_and_version_check() -> None:
	counts = Counts()
	counts.add(Token("chord", "ctrl+v"))
	counts.add(Token("modifier", "Control_L"))
	counts.break_sequence()
	data = counts.to_json("work", WORK_KEYMAP)
	assert data["version"] == 1
	assert data["host"] == "work"
	assert data["keymap"] == {
		"rules": "evdev",
		"model": "pc105",
		"layout": "fr",
		"variant": "us",
		"options": "lv3:ralt_switch,eurosign:4,caps:backspace,custom:no_backspace",
	}
	restored = Counts.from_json(data)
	assert restored.unigram == Counter({"ctrl+v": 1})
	assert restored.modifier == Counter({"Control_L": 1})
	assert restored.trigram == counts.trigram
	with pytest.raises(ValueError, match="unsupported state version"):
		Counts.from_json({**data, "version": 2})


def test_from_json_keeps_loaded_keymap() -> None:
	data = Counts().to_json("work", WORK_KEYMAP)
	assert Counts.from_json(data).loaded_keymap == data["keymap"]
	assert Counts().loaded_keymap is None


def test_dollar_and_caret_glyphs_are_not_sequence_markers() -> None:
	counts = Counts()
	counts.add(Token("glyph", "$"))
	counts.add(Token("glyph", "^"))
	counts.break_sequence()
	assert counts.trigram == Counter(
		{
			trigram(SEQUENCE_START, "$", "^"): 1,
			trigram("$", "^", SEQUENCE_END): 1,
		}
	)
	assert SEQUENCE_START not in ("$", "^")
	assert SEQUENCE_END not in ("$", "^")
