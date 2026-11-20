(() => {
	const SEQUENCE_START = "\u0002";
	const SEQUENCE_END = "\u0003";
	const TRIGRAM_SEPARATOR = "\u0000";
	const CHORD_PREFIXES = ["ctrl+", "alt+", "shift+", "super+"];

	const KEY_ROWS = [
		{
			row: "function",
			y: 0,
			keys: [
				[1, 0],
				[59, 1.5],
				[60, 2.5],
				[61, 3.5],
				[62, 4.5],
				[63, 5.75],
				[64, 6.75],
				[65, 7.75],
				[66, 8.75],
				[67, 10],
				[68, 11],
				[87, 12],
				[88, 13],
			],
		},
		{
			row: "number",
			y: 1.25,
			keys: [
				[41, 0],
				[2, 1],
				[3, 2],
				[4, 3],
				[5, 4],
				[6, 5],
				[7, 6],
				[8, 7],
				[9, 8],
				[10, 9],
				[11, 10],
				[12, 11],
				[13, 12],
				[14, 13, 2],
			],
		},
		{
			row: "top",
			y: 2.25,
			keys: [
				[15, 0, 1.5],
				[16, 1.5],
				[17, 2.5],
				[18, 3.5],
				[19, 4.5],
				[20, 5.5],
				[21, 6.5],
				[22, 7.5],
				[23, 8.5],
				[24, 9.5],
				[25, 10.5],
				[26, 11.5],
				[27, 12.5],
			],
		},
		{
			row: "home",
			y: 3.25,
			keys: [
				[58, 0, 1.75],
				[30, 1.75],
				[31, 2.75],
				[32, 3.75],
				[33, 4.75],
				[34, 5.75],
				[35, 6.75],
				[36, 7.75],
				[37, 8.75],
				[38, 9.75],
				[39, 10.75],
				[40, 11.75],
				[43, 12.75],
			],
		},
		{
			row: "bottom",
			y: 4.25,
			keys: [
				[42, 0, 1.25],
				[86, 1.25],
				[44, 2.25],
				[45, 3.25],
				[46, 4.25],
				[47, 5.25],
				[48, 6.25],
				[49, 7.25],
				[50, 8.25],
				[51, 9.25],
				[52, 10.25],
				[53, 11.25],
				[54, 12.25, 2.75],
			],
		},
		{
			row: "thumb",
			y: 5.25,
			keys: [
				[29, 0, 1.5],
				[125, 1.5, 1.25],
				[56, 2.75, 1.25],
				[57, 4, 6.25],
				[100, 10.25, 1.25],
				[126, 11.5, 1.25],
				[127, 12.75],
				[97, 13.75, 1.25],
			],
		},
		{
			row: "navigation",
			y: 1.25,
			keys: [
				[110, 15.5],
				[102, 16.5],
				[104, 17.5],
			],
		},
		{
			row: "navigation",
			y: 2.25,
			keys: [
				[111, 15.5],
				[107, 16.5],
				[109, 17.5],
			],
		},
		{ row: "navigation", y: 4.25, keys: [[103, 16.5]] },
		{
			row: "navigation",
			y: 5.25,
			keys: [
				[105, 15.5],
				[108, 16.5],
				[106, 17.5],
			],
		},
	];
	const ISO_ENTER = {
		code: 28,
		row: "top",
		x: 13.5,
		y: 2.25,
		w: 1.5,
		h: 2,
		shape: "iso-enter",
	};

	const KEYS = [
		...KEY_ROWS.flatMap(({ row, y, keys }) =>
			keys.map(([code, x, w = 1]) => ({ code, row, x, y, w, h: 1 })),
		),
		ISO_ENTER,
	];
	const BOARD_WIDTH = 18.5;
	const BOARD_HEIGHT = 6.25;

	const FINGER_KEYS = {
		LP: [1, 41, 2, 15, 16, 58, 30, 42, 86, 44, 29],
		LR: [3, 17, 31, 45],
		LM: [4, 18, 32, 46],
		LI: [5, 6, 19, 20, 33, 34, 47, 48],
		LT: [125, 56],
		T: [57],
		RT: [100, 126, 127],
		RI: [7, 8, 21, 22, 35, 36, 49, 50],
		RM: [9, 23, 37, 51],
		RR: [10, 24, 38, 52],
		RP: [11, 12, 13, 14, 25, 26, 27, 43, 39, 40, 28, 53, 54, 97],
	};
	const FINGERS = Object.keys(FINGER_KEYS);
	const FINGER_OF = new Map(
		Object.entries(FINGER_KEYS).flatMap(([finger, codes]) =>
			codes.map((code) => [code, finger]),
		),
	);
	const ROWS = ["number", "top", "home", "bottom", "thumb"];
	const ROW_OF = new Map(KEYS.map((key) => [key.code, key.row]));

	const handOf = (finger) => (finger?.length === 2 ? finger[0] : null);
	const isThumb = (finger) => finger?.endsWith("T") ?? false;

	function tokenKind(name) {
		if (
			CHORD_PREFIXES.some(
				(prefix) => name.startsWith(prefix) && name.length > prefix.length,
			)
		) {
			return "chord";
		}
		return [...name].length === 1 ? "glyph" : "named";
	}

	function addTo(map, key, amount) {
		map.set(key, (map.get(key) ?? 0) + amount);
	}

	const transitionCache = new WeakMap();

	function transitions(host) {
		const cached = transitionCache.get(host);
		if (cached) {
			return cached;
		}
		const next = new Map();
		const previous = new Map();
		for (const [first, second, third, count] of host.trigram) {
			if (!next.has(second)) {
				next.set(second, new Map());
			}
			if (!previous.has(second)) {
				previous.set(second, new Map());
			}
			addTo(next.get(second), third, count);
			addTo(previous.get(second), first, count);
		}
		const built = { next, previous };
		transitionCache.set(host, built);
		return built;
	}

	function strokesOf(host, layoutId, token) {
		return host.layouts[layoutId]?.[token];
	}

	function keyOf(host, layoutId, token) {
		const strokes = strokesOf(host, layoutId, token);
		return strokes ? strokes[strokes.length - 1][0] : undefined;
	}

	function keyUsage(hosts, layoutId, kinds) {
		const keys = new Map();
		const unplaced = new Map();
		const record = (code, token, count) => {
			if (!keys.has(code)) {
				keys.set(code, { count: 0, tokens: new Map() });
			}
			const entry = keys.get(code);
			entry.count += count;
			addTo(entry.tokens, token, count);
		};
		for (const host of hosts) {
			for (const [token, count] of Object.entries(host.unigram)) {
				if (!kinds.has(tokenKind(token))) {
					continue;
				}
				const strokes = strokesOf(host, layoutId, token);
				if (!strokes) {
					addTo(unplaced, token, count);
					continue;
				}
				for (const [code] of strokes) {
					record(code, token, count);
				}
			}
			if (kinds.has("modifier")) {
				for (const [name, count] of Object.entries(host.modifier)) {
					const code = host.modifierKeys[name];
					if (code === undefined) {
						addTo(unplaced, name, count);
					} else {
						record(code, name, count);
					}
				}
			}
		}
		return { keys, unplaced };
	}

	function keyFlow(hosts, layoutId, code, direction, kinds) {
		const targets = new Map();
		let edge = 0;
		let unplaced = 0;
		let total = 0;
		for (const host of hosts) {
			const table =
				transitions(host)[direction === "before" ? "previous" : "next"];
			for (const [token, neighbours] of table) {
				if (
					!kinds.has(tokenKind(token)) ||
					keyOf(host, layoutId, token) !== code
				) {
					continue;
				}
				for (const [neighbour, count] of neighbours) {
					if (neighbour === SEQUENCE_START || neighbour === SEQUENCE_END) {
						edge += count;
						total += count;
						continue;
					}
					if (!kinds.has(tokenKind(neighbour))) {
						continue;
					}
					total += count;
					const target = keyOf(host, layoutId, neighbour);
					if (target === undefined) {
						unplaced += count;
					} else {
						addTo(targets, target, count);
					}
				}
			}
		}
		return { targets, edge, unplaced, total };
	}

	function pairFlow(hosts, layoutId, firstCode, secondCode, kinds) {
		const targets = new Map();
		let edge = 0;
		let unplaced = 0;
		let total = 0;
		const matches = (host, token, code) =>
			kinds.has(tokenKind(token)) && keyOf(host, layoutId, token) === code;
		for (const host of hosts) {
			for (const [first, second, third, count] of host.trigram) {
				if (
					!matches(host, first, firstCode) ||
					!matches(host, second, secondCode)
				) {
					continue;
				}
				if (third === SEQUENCE_END) {
					edge += count;
					total += count;
					continue;
				}
				if (!kinds.has(tokenKind(third))) {
					continue;
				}
				total += count;
				const target = keyOf(host, layoutId, third);
				if (target === undefined) {
					unplaced += count;
				} else {
					addTo(targets, target, count);
				}
			}
		}
		return { targets, edge, unplaced, total };
	}

	function bigramClass(fromCode, toCode) {
		if (fromCode === toCode) {
			return "repeat";
		}
		const fromFinger = FINGER_OF.get(fromCode);
		const toFinger = FINGER_OF.get(toCode);
		if (!fromFinger || !toFinger || isThumb(fromFinger) || isThumb(toFinger)) {
			return "other";
		}
		if (fromFinger === toFinger) {
			return "sameFinger";
		}
		return handOf(fromFinger) === handOf(toFinger) ? "sameHand" : "alternate";
	}

	function layoutStats(hosts, layoutId, kinds) {
		const rows = new Map(ROWS.map((row) => [row, 0]));
		const fingers = new Map(FINGERS.map((finger) => [finger, 0]));
		const bigrams = new Map(
			["repeat", "sameFinger", "sameHand", "alternate", "other"].map((name) => [
				name,
				0,
			]),
		);
		let placed = 0;
		let total = 0;
		for (const host of hosts) {
			for (const [token, count] of Object.entries(host.unigram)) {
				if (!kinds.has(tokenKind(token))) {
					continue;
				}
				total += count;
				const code = keyOf(host, layoutId, token);
				if (code === undefined) {
					continue;
				}
				placed += count;
				if (rows.has(ROW_OF.get(code))) {
					addTo(rows, ROW_OF.get(code), count);
				}
				if (FINGER_OF.has(code)) {
					addTo(fingers, FINGER_OF.get(code), count);
				}
			}
			for (const [token, neighbours] of transitions(host).next) {
				if (!kinds.has(tokenKind(token))) {
					continue;
				}
				const fromCode = keyOf(host, layoutId, token);
				for (const [neighbour, count] of neighbours) {
					if (!kinds.has(tokenKind(neighbour))) {
						continue;
					}
					const toCode = keyOf(host, layoutId, neighbour);
					if (fromCode !== undefined && toCode !== undefined) {
						addTo(bigrams, bigramClass(fromCode, toCode), count);
					}
				}
			}
		}
		const fingerTotal = [...fingers.values()].reduce(
			(sum, count) => sum + count,
			0,
		);
		const handCount = (hand) =>
			FINGERS.filter((finger) => handOf(finger) === hand).reduce(
				(sum, finger) => sum + fingers.get(finger),
				0,
			);
		return {
			total,
			placed,
			rows,
			fingers,
			fingerTotal,
			hands: { L: handCount("L"), R: handCount("R") },
			bigrams,
			bigramTotal: [...bigrams.values()].reduce((sum, count) => sum + count, 0),
		};
	}

	function tokenRanking(hosts, kinds) {
		const rows = new Map();
		hosts.forEach((host, index) => {
			for (const [token, count] of Object.entries(host.unigram)) {
				if (!kinds.has(tokenKind(token))) {
					continue;
				}
				if (!rows.has(token)) {
					rows.set(token, { token, total: 0, perHost: hosts.map(() => 0) });
				}
				const row = rows.get(token);
				row.total += count;
				row.perHost[index] += count;
			}
		});
		return [...rows.values()].sort(
			(a, b) => b.total - a.total || a.token.localeCompare(b.token),
		);
	}

	function sortedEntries(map, limit) {
		return [...map.entries()].sort((a, b) => b[1] - a[1]).slice(0, limit);
	}

	function tokenDetail(hosts, token, limit) {
		const before = new Map();
		const after = new Map();
		const trigrams = new Map();
		for (const host of hosts) {
			const { next, previous } = transitions(host);
			for (const [neighbour, count] of next.get(token) ?? []) {
				addTo(after, neighbour, count);
			}
			for (const [neighbour, count] of previous.get(token) ?? []) {
				addTo(before, neighbour, count);
			}
			for (const [first, second, third, count] of host.trigram) {
				if (first === token || second === token || third === token) {
					addTo(
						trigrams,
						[first, second, third].join(TRIGRAM_SEPARATOR),
						count,
					);
				}
			}
		}
		const sum = (map) =>
			[...map.values()].reduce((total, count) => total + count, 0);
		return {
			before: sortedEntries(before, limit),
			beforeTotal: sum(before),
			after: sortedEntries(after, limit),
			afterTotal: sum(after),
			trigrams: sortedEntries(trigrams, limit).map(([key, count]) => [
				key.split(TRIGRAM_SEPARATOR),
				count,
			]),
		};
	}

	function keyShares(hosts, layoutId, kinds) {
		const { keys } = keyUsage(hosts, layoutId, kinds);
		const total = [...keys.values()].reduce(
			(sum, entry) => sum + entry.count,
			0,
		);
		return new Map(
			[...keys].map(([code, entry]) => [code, total ? entry.count / total : 0]),
		);
	}

	function keyDifference(firstHost, secondHost, layoutId, kinds) {
		const first = keyShares([firstHost], layoutId, kinds);
		const second = keyShares([secondHost], layoutId, kinds);
		const codes = new Set([...first.keys(), ...second.keys()]);
		return new Map(
			[...codes].map((code) => [
				code,
				{ first: first.get(code) ?? 0, second: second.get(code) ?? 0 },
			]),
		);
	}

	globalThis.keyheatModel = {
		SEQUENCE_START,
		SEQUENCE_END,
		KEYS,
		BOARD_WIDTH,
		BOARD_HEIGHT,
		FINGERS,
		FINGER_OF,
		ROWS,
		handOf,
		isThumb,
		tokenKind,
		transitions,
		keyOf,
		keyUsage,
		keyFlow,
		pairFlow,
		bigramClass,
		layoutStats,
		tokenRanking,
		tokenDetail,
		keyDifference,
	};
})();
