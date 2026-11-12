from collections import Counter

from conftest import trigram
from keyheat.counts import SEQUENCE_END, SEQUENCE_START
from keyheat.recorder import Recorder

BTN_LEFT = 0x110


def tap(recorder: Recorder, *codes: int, now: float, counting: bool = True) -> None:
	for code in codes:
		recorder.on_key(code, 1, now, counting=counting)
	for code in reversed(codes):
		recorder.on_key(code, 0, now, counting=counting)


def test_autorepeat_ignored(work_recorder: Recorder) -> None:
	work_recorder.on_key(18, 1, 0, counting=True)
	work_recorder.on_key(18, 2, 0.1, counting=True)
	work_recorder.on_key(18, 0, 0.2, counting=True)
	assert work_recorder.counts.unigram == Counter({"e": 1})


def test_consecutive_presses_share_a_sequence(work_recorder: Recorder) -> None:
	tap(work_recorder, 18, now=0)
	tap(work_recorder, 18, now=1)
	work_recorder.counts.break_sequence()
	assert trigram(SEQUENCE_START, "e", "e") in work_recorder.counts.trigram


def test_idle_breaks_sequence(work_recorder: Recorder) -> None:
	tap(work_recorder, 18, now=0)
	tap(work_recorder, 18, now=6)
	work_recorder.counts.break_sequence()
	assert work_recorder.counts.trigram == Counter(
		{trigram(SEQUENCE_START, "e", SEQUENCE_END): 2}
	)


def test_mouse_button_on_tap_breaks_and_is_not_a_token(work_recorder: Recorder) -> None:
	tap(work_recorder, 18, now=0)
	tap(work_recorder, BTN_LEFT, now=0.1)
	tap(work_recorder, 18, now=0.2)
	assert work_recorder.counts.unigram == Counter({"e": 2})
	assert trigram(SEQUENCE_START, "e", SEQUENCE_END) in work_recorder.counts.trigram


def test_pointer_breaks_sequence(work_recorder: Recorder) -> None:
	tap(work_recorder, 18, now=0)
	work_recorder.on_pointer()
	assert trigram(SEQUENCE_START, "e", SEQUENCE_END) in work_recorder.counts.trigram


def test_shift_held_through_pause_does_not_stick(work_recorder: Recorder) -> None:
	work_recorder.on_key(42, 1, 0, counting=True)
	work_recorder.on_key(42, 0, 0.1, counting=False)
	tap(work_recorder, 18, now=0.2)
	assert work_recorder.counts.unigram == Counter({"e": 1})


def test_shift_pressed_during_pause_still_applies(work_recorder: Recorder) -> None:
	work_recorder.on_key(42, 1, 0, counting=False)
	work_recorder.on_key(18, 1, 0.1, counting=True)
	assert work_recorder.counts.unigram == Counter({"E": 1})


def test_nothing_counted_while_gate_closed(work_recorder: Recorder) -> None:
	tap(work_recorder, 42, 18, now=0, counting=False)
	assert work_recorder.counts.unigram == Counter()
	assert work_recorder.counts.modifier == Counter()


def test_gate_change_breaks_sequence(work_recorder: Recorder) -> None:
	tap(work_recorder, 18, now=0)
	work_recorder.on_gate_change()
	assert trigram(SEQUENCE_START, "e", SEQUENCE_END) in work_recorder.counts.trigram


def test_pause_chord_never_counted(work_recorder: Recorder) -> None:
	tap(work_recorder, 29, 125, 37, now=0, counting=True)
	assert "ctrl+super+k" not in work_recorder.counts.unigram
	assert work_recorder.counts.modifier == Counter({"Control_L": 1, "Super_L": 1})


def test_resync_clears_stuck_modifier(work_recorder: Recorder) -> None:
	work_recorder.on_key(42, 1, 0, counting=True)
	work_recorder.on_resync(active_keys=[])
	tap(work_recorder, 18, now=0.1)
	assert work_recorder.counts.unigram == Counter({"e": 1})


def test_resync_replays_held_keys(work_recorder: Recorder) -> None:
	work_recorder.on_resync(active_keys=[42])
	work_recorder.on_key(18, 1, 0, counting=True)
	assert work_recorder.counts.unigram == Counter({"E": 1})


def test_resync_breaks_sequence(work_recorder: Recorder) -> None:
	tap(work_recorder, 18, now=0)
	work_recorder.on_resync(active_keys=[])
	assert trigram(SEQUENCE_START, "e", SEQUENCE_END) in work_recorder.counts.trigram
