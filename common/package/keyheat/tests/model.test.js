const assert = require("node:assert/strict");
const { test } = require("node:test");

require("../keyheat/viewer/model.js");
const model = globalThis.keyheatModel;

const START = model.SEQUENCE_START;
const END = model.SEQUENCE_END;

function host(name, overrides = {}) {
	return {
		name,
		unigram: { t: 3, h: 2, e: 4, "ctrl+v": 1, XF86AudioMute: 1 },
		modifier: { Control_L: 1, Hyper_L: 2 },
		modifierKeys: { Control_L: 29 },
		trigram: [
			[START, "t", "h", 2],
			["t", "h", "e", 2],
			["h", "e", END, 2],
			[START, "e", "e", 1],
			["e", "e", "t", 1],
			["e", "t", END, 1],
			[START, "ctrl+v", END, 1],
		],
		layouts: {
			native: {
				t: [[20, ""]],
				h: [[35, ""]],
				e: [[18, ""]],
				"ctrl+v": [[47, "ctrl"]],
			},
			swapped: {
				t: [[20, ""]],
				h: [[18, ""]],
				e: [
					[7, "altgr"],
					[35, ""],
				],
				"ctrl+v": [[47, "ctrl"]],
			},
		},
		...overrides,
	};
}

const ALL = new Set(["glyph", "named", "chord", "modifier"]);
const TYPED = new Set(["glyph", "named", "chord"]);

test("token kinds", () => {
	assert.equal(model.tokenKind("e"), "glyph");
	assert.equal(model.tokenKind(" "), "glyph");
	assert.equal(model.tokenKind("+"), "glyph");
	assert.equal(model.tokenKind("ctrl+v"), "chord");
	assert.equal(model.tokenKind("ctrl++"), "chord");
	assert.equal(model.tokenKind("BackSpace"), "named");
});

test("transitions come from trigram middles", () => {
	const { next, previous } = model.transitions(host("work"));
	assert.deepEqual(
		[...next.get("t")],
		[
			["h", 2],
			[END, 1],
		],
	);
	assert.deepEqual(
		[...previous.get("e")],
		[
			["h", 2],
			[START, 1],
			["e", 1],
		],
	);
});

test("key usage counts every stroke and recorded modifiers", () => {
	const { keys, unplaced } = model.keyUsage([host("work")], "swapped", ALL);
	assert.equal(keys.get(7).count, 4);
	assert.equal(keys.get(35).count, 4);
	assert.equal(keys.get(29).count, 1);
	assert.deepEqual(
		[...unplaced],
		[
			["XF86AudioMute", 1],
			["Hyper_L", 2],
		],
	);
});

test("key usage sums hosts and filters kinds", () => {
	const { keys } = model.keyUsage(
		[host("work"), host("jiruo")],
		"native",
		new Set(["glyph"]),
	);
	assert.equal(keys.get(18).count, 8);
	assert.equal(keys.has(47), false);
	assert.equal(keys.has(29), false);
});

test("key flow next and before", () => {
	const next = model.keyFlow([host("work")], "native", 18, "next", TYPED);
	assert.deepEqual(
		[...next.targets],
		[
			[18, 1],
			[20, 1],
		],
	);
	assert.equal(next.edge, 2);
	assert.equal(next.total, 4);
	const before = model.keyFlow([host("work")], "native", 18, "before", TYPED);
	assert.deepEqual(
		[...before.targets],
		[
			[35, 2],
			[18, 1],
		],
	);
	assert.equal(before.edge, 1);
});

test("key flow follows the layout", () => {
	const flow = model.keyFlow([host("work")], "swapped", 20, "next", TYPED);
	assert.deepEqual([...flow.targets], [[18, 2]]);
});

test("pair flow", () => {
	const flow = model.pairFlow([host("work")], "native", 20, 35, TYPED);
	assert.deepEqual([...flow.targets], [[18, 2]]);
	assert.equal(flow.total, 2);
});

test("bigram classes", () => {
	assert.equal(model.bigramClass(18, 18), "repeat");
	assert.equal(model.bigramClass(18, 32), "sameFinger");
	assert.equal(model.bigramClass(18, 20), "sameHand");
	assert.equal(model.bigramClass(18, 35), "alternate");
	assert.equal(model.bigramClass(57, 18), "other");
	assert.equal(model.bigramClass(103, 18), "other");
});

test("layout stats", () => {
	const stats = model.layoutStats([host("work")], "native", TYPED);
	assert.equal(stats.total, 11);
	assert.equal(stats.placed, 10);
	assert.equal(stats.rows.get("top"), 7);
	assert.equal(stats.rows.get("home"), 2);
	assert.equal(stats.rows.get("bottom"), 1);
	assert.equal(stats.hands.L, 8);
	assert.equal(stats.hands.R, 2);
	assert.equal(stats.bigrams.get("alternate"), 4);
	assert.equal(stats.bigrams.get("repeat"), 1);
	assert.equal(stats.bigrams.get("sameHand"), 1);
});

test("token ranking splits hosts", () => {
	const work = host("work");
	const jiruo = host("jiruo", { unigram: { e: 10 } });
	const ranking = model.tokenRanking([work, jiruo], new Set(["glyph"]));
	assert.deepEqual(ranking[0], { token: "e", total: 14, perHost: [4, 10] });
	assert.deepEqual(
		ranking.map((row) => row.token),
		["e", "t", "h"],
	);
});

test("token detail", () => {
	const detail = model.tokenDetail([host("work")], "e", 10);
	assert.deepEqual(detail.before, [
		["h", 2],
		[START, 1],
		["e", 1],
	]);
	assert.deepEqual(detail.after, [
		[END, 2],
		["e", 1],
		["t", 1],
	]);
	assert.equal(detail.afterTotal, 4);
	assert.deepEqual(detail.trigrams[0], [["t", "h", "e"], 2]);
});

test("key difference uses per host shares", () => {
	const work = host("work");
	const jiruo = host("jiruo", { unigram: { e: 10 }, modifier: {} });
	const difference = model.keyDifference(
		work,
		jiruo,
		"native",
		new Set(["glyph"]),
	);
	assert.deepEqual(difference.get(18), { first: 4 / 9, second: 1 });
	assert.deepEqual(difference.get(20), { first: 3 / 9, second: 0 });
});

test("every key has a finger or is navigation", () => {
	for (const key of model.KEYS) {
		const hasFinger = model.FINGER_OF.has(key.code);
		assert.equal(
			hasFinger,
			!["navigation", "function"].includes(key.row) || key.code === 1,
			`${key.code}`,
		);
	}
});
