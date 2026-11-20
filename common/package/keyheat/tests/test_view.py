import json
import re
import stat
from pathlib import Path

import pytest
from conftest import JIRUO_KEYMAP, WORK_KEYMAP, XKB_DIR
from keyheat.counts import Counts
from keyheat.resolve import Token
from keyheat.view import (
	ALTERNATE_LAYOUTS,
	KeyFinder,
	ViewError,
	alternate_keymap,
	build_payload,
	embedded_json,
	load_host,
	main,
	render_html,
	split_chord,
)

SVG_NAMESPACE = "http://www.w3.org/2000/svg"


def layout_finder(layout_id: str) -> KeyFinder:
	layout = next(layout for layout in ALTERNATE_LAYOUTS if layout.id == layout_id)
	return KeyFinder(alternate_keymap(layout, XKB_DIR))


@pytest.fixture(scope="module")
def work_finder() -> KeyFinder:
	return KeyFinder(WORK_KEYMAP)


@pytest.fixture(scope="module")
def jiruo_finder() -> KeyFinder:
	return KeyFinder(JIRUO_KEYMAP)


def host_data(host: str, keymap: dict | None = None) -> dict:
	counts = Counts()
	for name in ("t", "h", "e"):
		counts.add(Token("glyph", name))
	counts.add(Token("chord", "ctrl+v"))
	counts.add(Token("modifier", "Control_L"))
	counts.break_sequence()
	data = counts.to_json(host, WORK_KEYMAP)
	if keymap:
		data["keymap"] = keymap
	return data


def test_plain_shift_and_altgr_glyphs(work_finder: KeyFinder) -> None:
	assert work_finder.strokes("e") == [(18, "")]
	assert work_finder.strokes("$") == [(5, "shift")]
	assert work_finder.strokes("é") == [(18, "altgr")]
	assert work_finder.strokes("€") == [(5, "altgr")]


def test_dead_key_glyph_is_two_strokes(work_finder: KeyFinder) -> None:
	assert work_finder.strokes("ö") == [(40, "altgr"), (24, "")]
	assert work_finder.strokes("ê") == [(32, "altgr")]


def test_jiruo_direct_accent(jiruo_finder: KeyFinder) -> None:
	assert jiruo_finder.strokes("ç") == [(46, "altgr")]
	assert jiruo_finder.strokes("ê") == [(4, "altgr")]


def test_named_tokens(work_finder: KeyFinder) -> None:
	assert work_finder.strokes("BackSpace") == [(58, "")]
	assert work_finder.strokes("Return") == [(28, "")]
	assert work_finder.strokes("<") == [(14, "")]
	assert work_finder.strokes("VoidSymbol") == [(14, "")]


def test_chords_land_on_base_key(work_finder: KeyFinder) -> None:
	assert work_finder.strokes("ctrl+v") == [(47, "ctrl")]
	assert work_finder.strokes("ctrl+shift+=") == [(13, "ctrl+shift")]
	assert work_finder.strokes("super+Return") == [(28, "super")]
	assert work_finder.strokes("ctrl+BackSpace") == [(58, "ctrl")]
	assert work_finder.strokes("ctrl+VoidSymbol") == [(14, "ctrl")]


def test_unknown_token_is_unplaced(work_finder: KeyFinder) -> None:
	assert work_finder.strokes("XF86AudioMute") is None
	assert work_finder.strokes("ctrl+XF86AudioMute") is None


def test_modifier_keys(work_finder: KeyFinder) -> None:
	assert work_finder.modifiers["Shift_L"] == 42
	assert work_finder.modifiers["ISO_Level3_Shift"] == 100
	assert work_finder.modifiers["Super_L"] == 125


def test_keypad_never_wins(work_finder: KeyFinder) -> None:
	assert work_finder.strokes("*") == [(9, "shift")]
	assert work_finder.strokes("/") == [(53, "")]


def test_alternate_layouts_move_glyphs() -> None:
	assert layout_finder("colemak").strokes("e") == [(37, "")]
	assert layout_finder("dvorak").strokes("e") == [(32, "")]
	assert layout_finder("colemak").strokes("ctrl+v") == [(47, "ctrl")]
	assert layout_finder("dvorak").strokes("ctrl+v") == [(52, "ctrl")]


def test_split_chord() -> None:
	assert split_chord("ctrl+shift+t") == ("ctrl+shift", "t")
	assert split_chord("ctrl++") == ("ctrl", "+")
	assert split_chord("+") is None
	assert split_chord("e") is None


def test_payload_hosts_and_layouts() -> None:
	payload = build_payload([host_data("work")], XKB_DIR)
	(host,) = payload["hosts"]
	assert host["name"] == "work"
	assert host["layouts"]["native"]["e"] == [(18, "")]
	assert host["layouts"]["colemak"]["e"] == [(37, "")]
	assert ["\u0002", "t", "h", 1] in host["trigram"]
	assert host["modifier"] == {"Control_L": 1}
	assert [layout["id"] for layout in payload["layouts"]][:2] == ["native", "qwerty"]


def test_duplicate_host_rejected() -> None:
	with pytest.raises(ViewError, match="work"):
		build_payload([host_data("work"), host_data("work")], XKB_DIR)


def test_load_host_rejects_bad_files(tmp_path: Path) -> None:
	broken = tmp_path / "broken.json"
	broken.write_text("{")
	with pytest.raises(ViewError):
		load_host(broken)
	partial = tmp_path / "partial.json"
	partial.write_text(json.dumps({"version": 1, "host": "work"}))
	with pytest.raises(ViewError, match="keymap"):
		load_host(partial)


def test_embedded_json_cannot_close_script() -> None:
	text = embedded_json({"unigram": {"</script>": 1}})
	assert "</script>" not in text
	assert json.loads(text) == {"unigram": {"</script>": 1}}


def test_html_is_self_contained() -> None:
	html = render_html(build_payload([host_data("work")], XKB_DIR))
	assert "default-src 'none'" in html
	assert "{{" not in html
	assert not re.search(r"https?://", html.replace(SVG_NAMESPACE, ""))
	assert not re.search(r"<(script|link|img)[^>]*\s(src|href)=", html)


def test_main_writes_private_file(tmp_path: Path) -> None:
	state = tmp_path / "work.json"
	state.write_text(json.dumps(host_data("work")))
	output = tmp_path / "view.html"
	main([str(state), "--output", str(output), "--xkb-dir", str(XKB_DIR)])
	assert stat.S_IMODE(output.stat().st_mode) == 0o600
	assert '"name":"work"' in output.read_text(encoding="utf-8")


def test_labels_per_level(work_finder: KeyFinder) -> None:
	assert work_finder.labels[18] == {
		"": "e",
		"shift": "E",
		"altgr": "é",
		"shift+altgr": "É",
	}
	assert work_finder.labels[7]["altgr"] == "dead"
	assert work_finder.labels[28][""] == "Return"
