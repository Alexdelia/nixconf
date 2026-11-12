import os

import pytest
from keyheat.counts import Counts
from keyheat.recorder import Recorder
from keyheat.resolve import Keymap, KeyResolver, Token

XKB_DIR = os.environ.get("KEYHEAT_TEST_XKB_DIR")

JIRUO_KEYMAP = Keymap(
	rules="evdev",
	model="pc105",
	layout="qwerty-dev-ca",
	variant="",
	options="caps:backspace,custom:no_backspace",
	include_dir=XKB_DIR,
)

WORK_KEYMAP = Keymap(
	rules="evdev",
	model="pc105",
	layout="fr",
	variant="us",
	options="lv3:ralt_switch,eurosign:4,caps:backspace,custom:no_backspace",
	include_dir=XKB_DIR,
)


@pytest.fixture
def jiruo_resolver() -> KeyResolver:
	return KeyResolver(JIRUO_KEYMAP)


@pytest.fixture
def work_resolver() -> KeyResolver:
	return KeyResolver(WORK_KEYMAP)


def type_keys(resolver: KeyResolver, *codes: int) -> Token | None:
	last_token = None
	for code in codes:
		last_token = resolver.press(code)
	for code in reversed(codes):
		resolver.release(code)
	return last_token


def trigram(first: str, second: str, third: str) -> str:
	return f"{first}\x00{second}\x00{third}"


@pytest.fixture
def work_recorder(work_resolver: KeyResolver) -> Recorder:
	return Recorder(work_resolver, Counts(), ignored_chord="ctrl+super+k")
