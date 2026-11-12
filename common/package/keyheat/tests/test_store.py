import json
import stat
from collections import Counter
from pathlib import Path

import pytest
from keyheat.store import FlushPolicy, StateFileError, load, save


def test_missing_file_gives_empty_counts(tmp_path: Path) -> None:
	assert load(tmp_path / "work.json").unigram == Counter()


def test_existing_file_is_loaded(tmp_path: Path) -> None:
	path = tmp_path / "work.json"
	path.write_text(
		json.dumps({"version": 1, "unigram": {"e": 3}, "modifier": {}, "trigram": {}})
	)
	assert load(path).unigram == Counter({"e": 3})


def test_corrupt_file_raises_and_is_untouched(tmp_path: Path) -> None:
	path = tmp_path / "work.json"
	path.write_text("{not json")
	with pytest.raises(StateFileError):
		load(path)
	assert path.read_text() == "{not json"


def test_wrong_version_raises(tmp_path: Path) -> None:
	path = tmp_path / "work.json"
	path.write_text(json.dumps({"version": 2}))
	with pytest.raises(StateFileError):
		load(path)


def test_save_is_atomic_with_mode_0640(tmp_path: Path) -> None:
	path = tmp_path / "work.json"
	save(path, {"version": 1, "unigram": {"é": 1}})
	assert stat.S_IMODE(path.stat().st_mode) == 0o640
	assert json.loads(path.read_text(encoding="utf-8"))["unigram"] == {"é": 1}
	assert not path.with_suffix(".json.tmp").exists()


def test_save_overwrites_previous_state(tmp_path: Path) -> None:
	path = tmp_path / "work.json"
	save(path, {"version": 1, "unigram": {"a": 1}})
	save(path, {"version": 1, "unigram": {"b": 2}})
	assert json.loads(path.read_text(encoding="utf-8"))["unigram"] == {"b": 2}


def test_flush_needs_both_interval_and_threshold() -> None:
	policy = FlushPolicy(started_at=0, min_tokens=2000, interval_seconds=3600)
	assert not policy.due(now=3600, tokens=1999)
	assert not policy.due(now=3599, tokens=5000)
	assert policy.due(now=3600, tokens=2000)
	policy.flushed(now=3600)
	assert not policy.due(now=7199, tokens=9000)
	assert policy.due(now=7200, tokens=9000)


def test_exit_flush_threshold() -> None:
	policy = FlushPolicy(started_at=0, min_tokens=2000, interval_seconds=3600)
	assert not policy.due_on_exit(1999)
	assert policy.due_on_exit(2000)


def test_non_object_json_raises(tmp_path: Path) -> None:
	path = tmp_path / "work.json"
	path.write_text("[]")
	with pytest.raises(StateFileError):
		load(path)
