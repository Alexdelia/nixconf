(() => {
	const model = globalThis.keyheatModel;
	const data = JSON.parse(document.getElementById("keyheat-data").textContent);
	const SVG = "http://www.w3.org/2000/svg";
	const UNIT = 60;
	const KINDS = ["glyph", "named", "chord", "modifier"];
	const TYPED_KINDS = ["glyph", "named", "chord"];
	const ALL_HOSTS = "all";
	const DIFFERENCE_LIMIT = 2;
	const RANKING_LIMIT = 400;
	const DETAIL_LIMIT = 15;
	const FLOW_COLORS = {
		alternate: "--flow-alternate",
		sameHand: "--flow-same-hand",
		sameFinger: "--flow-same-finger",
		repeat: "--flow-repeat",
		other: "--flow-other",
	};
	const FLOW_LABELS = {
		alternate: "hand alternation",
		sameHand: "same hand",
		sameFinger: "same finger",
		repeat: "same key",
		other: "thumb or other",
	};
	const FINGER_LABELS = {
		LP: "L pinky",
		LR: "L ring",
		LM: "L middle",
		LI: "L index",
		LT: "L thumb",
		T: "space",
		RT: "R thumb",
		RI: "R index",
		RM: "R middle",
		RR: "R ring",
		RP: "R pinky",
	};
	const KEY_NAMES = {
		BackSpace: "⌫",
		Return: "⏎",
		Tab: "⇥",
		ISO_Left_Tab: "⇤",
		Escape: "esc",
		Up: "↑",
		Down: "↓",
		Left: "←",
		Right: "→",
		Home: "home",
		End: "end",
		Prior: "pgup",
		Next: "pgdn",
		Insert: "ins",
		Delete: "del",
		Menu: "menu",
		Caps_Lock: "caps",
		Shift_L: "⇧",
		Shift_R: "⇧",
		Control_L: "ctrl",
		Control_R: "ctrl",
		Alt_L: "alt",
		Alt_R: "alt",
		Super_L: "super",
		Super_R: "super",
		ISO_Level3_Shift: "altgr",
		dead: "◌",
		" ": "space",
	};

	const state = {
		tab: "board",
		host: ALL_HOSTS,
		layout: "native",
		kinds: new Set(KINDS),
		colorMode: "usage",
		scale: "sqrt",
		direction: "next",
		top: 8,
		handColors: false,
		trigramMode: false,
		pins: [],
		hover: null,
		token: null,
		search: "",
	};

	const $ = (id) => document.getElementById(id);

	function el(tag, attributes = {}, ...children) {
		const node = document.createElement(tag);
		for (const [name, value] of Object.entries(attributes)) {
			if (name === "class") {
				node.className = value;
			} else if (name === "style") {
				Object.assign(node.style, value);
			} else if (name.startsWith("on")) {
				node.addEventListener(name.slice(2), value);
			} else {
				node.setAttribute(name, value);
			}
		}
		node.append(
			...children
				.flat()
				.filter((child) => child !== null && child !== undefined),
		);
		return node;
	}

	function svg(tag, attributes = {}, ...children) {
		const node = document.createElementNS(SVG, tag);
		for (const [name, value] of Object.entries(attributes)) {
			node.setAttribute(name, value);
		}
		node.append(...children);
		return node;
	}

	const cssVariable = (name) =>
		getComputedStyle(document.documentElement).getPropertyValue(name).trim();

	function hexToRgb(hex) {
		const value = Number.parseInt(hex.slice(1), 16);
		return [(value >> 16) & 255, (value >> 8) & 255, value & 255];
	}

	function mix(first, second, ratio) {
		const a = hexToRgb(first);
		const b = hexToRgb(second);
		const channels = a.map((channel, index) =>
			Math.round(channel + (b[index] - channel) * ratio),
		);
		return `rgb(${channels.join(" ")})`;
	}

	function rampColor(stops, ratio) {
		const position = Math.min(Math.max(ratio, 0), 1) * (stops.length - 1);
		const index = Math.min(Math.floor(position), stops.length - 2);
		return mix(stops[index], stops[index + 1], position - index);
	}

	function readableText(color) {
		const channels = color.match(/\d+/g).map(Number);
		const [red, green, blue] = channels.map((channel) => {
			const linear = channel / 255;
			return linear <= 0.03928
				? linear / 12.92
				: ((linear + 0.055) / 1.055) ** 2.4;
		});
		const luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue;
		return luminance > 0.35 ? "#0b0b0b" : "#ffffff";
	}

	const percent = (value, digits = 1) => `${(value * 100).toFixed(digits)}%`;
	const share = (part, whole) => (whole ? part / whole : 0);
	const formatCount = (value) => value.toLocaleString("en-US");

	function selectedHosts() {
		return state.host === ALL_HOSTS
			? data.hosts
			: data.hosts.filter((host) => host.name === state.host);
	}

	function typedKinds() {
		return new Set(TYPED_KINDS.filter((kind) => state.kinds.has(kind)));
	}

	function tokenLabel(token) {
		if (token === model.SEQUENCE_START) {
			return el("span", { class: "token special" }, "start");
		}
		if (token === model.SEQUENCE_END) {
			return el("span", { class: "token special" }, "end");
		}
		if (token === " ") {
			return el("span", { class: "token" }, "␣");
		}
		return el("span", { class: "token" }, token);
	}

	function keyName(name) {
		if (name === undefined) {
			return "";
		}
		if (KEY_NAMES[name]) {
			return KEY_NAMES[name];
		}
		return name.length > 5 ? name.slice(0, 5) : name;
	}

	function keyLabels(code) {
		const host = selectedHosts()[0] ?? data.hosts[0];
		const labels = host.labels[state.layout]?.[code] ?? {};
		const modifier = Object.entries(host.modifierKeys).find(
			([, value]) => value === code,
		);
		return {
			base: modifier ? keyName(modifier[0]) : keyName(labels[""]),
			altgr:
				labels.altgr && labels.altgr !== labels[""]
					? keyName(labels.altgr)
					: "",
		};
	}

	function readHash() {
		const params = new URLSearchParams(location.hash.slice(1));
		const text = (name) => params.get(name);
		state.tab = text("tab") ?? state.tab;
		state.host = text("host") ?? state.host;
		state.layout = text("layout") ?? state.layout;
		if (params.has("kinds")) {
			state.kinds = new Set(
				text("kinds")
					.split(",")
					.filter((kind) => KINDS.includes(kind)),
			);
		}
		state.colorMode = text("color") ?? state.colorMode;
		state.scale = text("scale") ?? state.scale;
		state.direction = text("dir") ?? state.direction;
		state.top = Number(text("top") ?? state.top);
		state.handColors = text("hands") === "1";
		state.trigramMode = text("trigram") === "1";
		state.pins = (text("pins") ?? "").split(",").filter(Boolean).map(Number);
		state.token = text("token");
		if (!data.hosts.some((host) => host.name === state.host)) {
			state.host = ALL_HOSTS;
		}
		if (!data.layouts.some((layout) => layout.id === state.layout)) {
			state.layout = "native";
		}
	}

	function writeHash() {
		const params = new URLSearchParams({
			tab: state.tab,
			host: state.host,
			layout: state.layout,
			kinds: [...state.kinds].join(","),
			color: state.colorMode,
			scale: state.scale,
			dir: state.direction,
			top: String(state.top),
			hands: state.handColors ? "1" : "0",
			trigram: state.trigramMode ? "1" : "0",
		});
		if (state.pins.length) {
			params.set("pins", state.pins.join(","));
		}
		if (state.token !== null) {
			params.set("token", state.token);
		}
		history.replaceState(null, "", `#${params}`);
	}

	function update(changes) {
		Object.assign(state, changes);
		writeHash();
		render();
	}

	function setPressed(container, value) {
		for (const button of container.querySelectorAll("button")) {
			button.setAttribute(
				"aria-pressed",
				String(button.dataset.value === value),
			);
		}
	}

	function bindSegmented(id, key) {
		$(id).addEventListener("click", (event) => {
			const button = event.target.closest("button");
			if (button && !button.disabled) {
				update({ [key]: button.dataset.value });
			}
		});
	}

	function setupControls() {
		const hosts = $("hosts");
		const hostOptions = [ALL_HOSTS, ...data.hosts.map((host) => host.name)];
		for (const name of hostOptions) {
			hosts.append(
				el(
					"button",
					{ type: "button", "data-value": name },
					name === ALL_HOSTS
						? data.hosts.length > 1
							? "combined"
							: "all"
						: name,
				),
			);
		}
		if (data.hosts.length === 1) {
			hosts.firstChild.remove();
			state.host = data.hosts[0].name;
		}
		bindSegmented("hosts", "host");
		bindSegmented("color-mode", "colorMode");
		bindSegmented("scale", "scale");
		bindSegmented("direction", "direction");

		for (const layout of data.layouts) {
			$("layout").append(el("option", { value: layout.id }, layout.label));
		}
		$("layout").addEventListener("change", (event) =>
			update({ layout: event.target.value }),
		);

		$("tabs").addEventListener("click", (event) => {
			const button = event.target.closest("button");
			if (button) {
				update({ tab: button.dataset.tab });
			}
		});

		$("kinds").addEventListener("change", () => {
			const kinds = new Set(
				[...$("kinds").querySelectorAll("input:checked")].map(
					(input) => input.value,
				),
			);
			update({ kinds });
		});

		$("top").addEventListener("input", (event) =>
			update({ top: Number(event.target.value) }),
		);
		$("hand-colors").addEventListener("change", (event) =>
			update({ handColors: event.target.checked }),
		);
		$("trigram-mode").addEventListener("change", (event) =>
			update({ trigramMode: event.target.checked, pins: [] }),
		);
		$("token-search").addEventListener("input", (event) => {
			state.search = event.target.value;
			renderRanking();
		});

		document.addEventListener("keydown", (event) => {
			if (event.key === "Escape") {
				update({ pins: [] });
			}
		});
		$("board").addEventListener("pointerleave", () => {
			state.hover = null;
			hideTooltip();
			renderBoard();
		});
		window
			.matchMedia("(prefers-color-scheme: dark)")
			.addEventListener("change", () => render());
	}

	function syncControls() {
		for (const button of $("tabs").querySelectorAll("button")) {
			button.setAttribute(
				"aria-pressed",
				String(button.dataset.tab === state.tab),
			);
		}
		setPressed($("hosts"), state.host);
		setPressed($("color-mode"), state.colorMode);
		setPressed($("scale"), state.scale);
		setPressed($("direction"), state.direction);
		const differenceButton = $("color-mode").querySelector(
			'[data-value="difference"]',
		);
		differenceButton.disabled = data.hosts.length < DIFFERENCE_LIMIT;
		differenceButton.title = differenceButton.disabled
			? "needs two host files"
			: "";
		if (differenceButton.disabled && state.colorMode === "difference") {
			state.colorMode = "usage";
			setPressed($("color-mode"), state.colorMode);
		}
		$("layout").value = state.layout;
		for (const input of $("kinds").querySelectorAll("input")) {
			input.checked = state.kinds.has(input.value);
		}
		$("top").value = String(state.top);
		$("top-value").value = String(state.top);
		$("hand-colors").checked = state.handColors;
		$("trigram-mode").checked = state.trigramMode;
		$("board-view").classList.toggle("active", state.tab === "board");
		$("tokens-view").classList.toggle("active", state.tab !== "board");
	}

	function scaleValue(value, max) {
		if (!max || !value) {
			return 0;
		}
		if (state.scale === "linear") {
			return value / max;
		}
		if (state.scale === "log") {
			return Math.log1p(value) / Math.log1p(max);
		}
		return Math.sqrt(value / max);
	}

	function heatStops() {
		return Array.from({ length: 9 }, (_, index) =>
			cssVariable(`--heat-${index}`),
		);
	}

	function differenceRatio(entry) {
		const smallest = 1e-4;
		const ratio = Math.log2(
			(entry.first + smallest) / (entry.second + smallest),
		);
		return Math.max(-2, Math.min(2, ratio)) / 2;
	}

	function keyFills() {
		const fills = new Map();
		if (state.colorMode === "difference") {
			const [first, second] = data.hosts;
			const difference = model.keyDifference(
				first,
				second,
				state.layout,
				state.kinds,
			);
			const firstColor = cssVariable("--diverge-first");
			const middle = cssVariable("--diverge-middle");
			const secondColor = cssVariable("--diverge-second");
			for (const [code, entry] of difference) {
				const ratio = differenceRatio(entry);
				fills.set(
					code,
					ratio >= 0
						? mix(middle, firstColor, ratio)
						: mix(middle, secondColor, -ratio),
				);
			}
			return { fills, difference };
		}
		const usage = model.keyUsage(selectedHosts(), state.layout, state.kinds);
		const max = Math.max(
			0,
			...[...usage.keys.values()].map((entry) => entry.count),
		);
		const stops = heatStops();
		for (const [code, entry] of usage.keys) {
			fills.set(code, rampColor(stops, scaleValue(entry.count, max)));
		}
		return { fills, usage };
	}

	function keyCenter(key) {
		if (key.shape === "iso-enter") {
			return [
				(key.x + 0.25 + (key.w - 0.25) / 2) * UNIT,
				(key.y + key.h / 2) * UNIT,
			];
		}
		return [(key.x + key.w / 2) * UNIT, (key.y + key.h / 2) * UNIT];
	}

	function keyShape(key, fill) {
		if (key.shape === "iso-enter") {
			const points = [
				[key.x, key.y],
				[key.x + key.w, key.y],
				[key.x + key.w, key.y + key.h],
				[key.x + 0.25, key.y + key.h],
				[key.x + 0.25, key.y + 1],
				[key.x, key.y + 1],
			];
			const path = points
				.map(([x, y], index) => `${index ? "L" : "M"}${x * UNIT} ${y * UNIT}`)
				.join(" ");
			return svg("path", { d: `${path} Z`, fill });
		}
		return svg("rect", {
			x: key.x * UNIT,
			y: key.y * UNIT,
			width: key.w * UNIT,
			height: key.h * UNIT,
			rx: 7,
			fill,
		});
	}

	function activeFlow() {
		const kinds = typedKinds();
		const hosts = selectedHosts();
		const [firstPin, secondPin] = state.pins;
		if (state.trigramMode && firstPin !== undefined) {
			const second = secondPin ?? state.hover;
			if (second !== null && second !== undefined) {
				return {
					source: second,
					pair: [firstPin, second],
					flow: model.pairFlow(hosts, state.layout, firstPin, second, kinds),
				};
			}
			return {
				source: firstPin,
				flow: model.keyFlow(hosts, state.layout, firstPin, "next", kinds),
			};
		}
		const source = firstPin ?? state.hover;
		if (source === null || source === undefined) {
			return null;
		}
		return {
			source,
			flow: model.keyFlow(hosts, state.layout, source, state.direction, kinds),
		};
	}

	function flowColor(source, target, direction) {
		if (!state.handColors) {
			return cssVariable("--flow");
		}
		const kind =
			direction === "before"
				? model.bigramClass(target, source)
				: model.bigramClass(source, target);
		return cssVariable(FLOW_COLORS[kind]);
	}

	function renderBoard() {
		const board = $("board");
		const width = model.BOARD_WIDTH * UNIT;
		const height = model.BOARD_HEIGHT * UNIT;
		board.setAttribute("viewBox", `-4 -4 ${width + 8} ${height + 8}`);
		const { fills } = keyFills();
		const empty = cssVariable("--key-empty");
		const keysByCode = new Map(model.KEYS.map((key) => [key.code, key]));
		const active = state.tab === "board" ? activeFlow() : null;
		const direction = state.trigramMode ? "next" : state.direction;
		const shown = active
			? [...active.flow.targets.entries()]
					.sort((a, b) => b[1] - a[1])
					.slice(0, state.top)
					.filter(([code]) => keysByCode.has(code))
			: [];
		const shares = new Map(
			shown.map(([code, count]) => [code, share(count, active.flow.total)]),
		);
		const largestShare = Math.max(0, ...shares.values());

		const keyLayer = svg("g");
		for (const key of model.KEYS) {
			const fill = fills.get(key.code) ?? empty;
			const textColor =
				fill === empty ? cssVariable("--text-muted") : readableText(fill);
			const labels = keyLabels(key.code);
			const [centerX, centerY] = keyCenter(key);
			const pinned = state.pins.includes(key.code);
			const group = svg("g", {
				class: `key${pinned ? " pinned" : ""}`,
				"data-code": key.code,
			});
			group.append(keyShape(key, fill));
			group.append(
				svg(
					"text",
					{ class: "base", x: centerX, y: centerY, fill: textColor },
					labels.base,
				),
			);
			if (labels.altgr) {
				group.append(
					svg(
						"text",
						{
							class: "level",
							x: (key.x + key.w) * UNIT - 10,
							y: (key.y + key.h) * UNIT - 10,
							fill: textColor,
						},
						labels.altgr,
					),
				);
			}
			group.addEventListener("pointerenter", (event) => {
				if (state.hover !== key.code) {
					state.hover = key.code;
					renderBoard();
				}
				showKeyTooltip(key.code, event);
			});
			group.addEventListener("pointermove", (event) => moveTooltip(event));
			group.addEventListener("click", () => pinKey(key.code));
			keyLayer.append(group);
		}

		const flowLayer = svg("g", { class: "flow" });
		const badgeLayer = svg("g", { class: "badges" });
		if (active) {
			const sourceKey = keysByCode.get(active.source);
			const [sourceX, sourceY] = sourceKey ? keyCenter(sourceKey) : [0, 0];
			for (const [code, value] of shares) {
				const target = keysByCode.get(code);
				const [targetX, targetY] = keyCenter(target);
				const color = flowColor(active.source, code, direction);
				const weight = share(value, largestShare);
				const strokeWidth = 3 + 15 * weight;
				const opacity = 0.22 + 0.33 * weight;
				if (code === active.source) {
					flowLayer.append(
						svg("circle", {
							cx: sourceX,
							cy: sourceY,
							r: UNIT * 0.42,
							stroke: color,
							"stroke-width": strokeWidth,
							"stroke-opacity": opacity,
						}),
					);
				} else if (sourceKey) {
					flowLayer.append(
						svg("line", {
							x1: sourceX,
							y1: sourceY,
							x2: targetX,
							y2: targetY,
							stroke: color,
							"stroke-width": strokeWidth,
							"stroke-opacity": opacity,
						}),
					);
				}
				const badgeX = (target.x + target.w) * UNIT - 4;
				const badgeY = target.y * UNIT + 4;
				const text = percent(value, value < 0.1 ? 1 : 0);
				badgeLayer.append(
					svg("rect", {
						x: badgeX - 8 - text.length * 6,
						y: badgeY,
						width: 6 + text.length * 6,
						height: 15,
						rx: 4,
						fill: cssVariable("--surface-raised"),
						"fill-opacity": 0.92,
					}),
					svg(
						"text",
						{ x: badgeX - 5, y: badgeY + 8, fill: cssVariable("--text") },
						text,
					),
				);
			}
		}
		board.replaceChildren(keyLayer, flowLayer, badgeLayer);
		renderFlowInfo(active, shown);
		renderLegend();
	}

	function pinKey(code) {
		if (state.trigramMode) {
			update({ pins: state.pins.length >= 2 ? [code] : [...state.pins, code] });
			return;
		}
		update({ pins: state.pins[0] === code ? [] : [code] });
	}

	function describeKey(code) {
		return keyLabels(code).base || `#${code}`;
	}

	function renderFlowInfo(active, shown) {
		const info = $("flow-info");
		const detail = $("key-detail");
		if (!active) {
			info.textContent = state.trigramMode
				? "trigram mode: click a first key, then hover or click a second key"
				: "hover a key to see where it goes; click to pin, Esc to clear";
			detail.replaceChildren();
			return;
		}
		const { flow } = active;
		const title = active.pair
			? `after ${describeKey(active.pair[0])} then ${describeKey(active.pair[1])}`
			: `${state.direction === "before" && !state.trigramMode ? "before" : "after"} ${describeKey(active.source)}`;
		const shownTotal = shown.reduce((sum, [, count]) => sum + count, 0);
		info.textContent = `${title}: ${formatCount(flow.total)} transitions, top ${shown.length} cover ${percent(share(shownTotal, flow.total))}, sequence edge ${percent(share(flow.edge, flow.total))}, unplaced ${percent(share(flow.unplaced, flow.total))}`;
		detail.replaceChildren(
			el("h2", {}, title),
			el(
				"table",
				{},
				el(
					"thead",
					{},
					el(
						"tr",
						{},
						el("th", {}, "key"),
						el("th", {}, "count"),
						el("th", {}, "share"),
					),
				),
				el(
					"tbody",
					{},
					shown.map(([code, count]) =>
						el(
							"tr",
							{},
							el("td", {}, describeKey(code)),
							el("td", {}, formatCount(count)),
							el("td", {}, percent(share(count, flow.total))),
						),
					),
				),
			),
		);
	}

	function renderLegend() {
		const legend = $("legend");
		const items = [];
		if (state.colorMode === "difference") {
			const [first, second] = data.hosts;
			items.push(
				el("span", {}, `more on ${first.name} `),
				el("span", {
					class: "ramp",
					style: {
						background: `linear-gradient(to left, ${cssVariable("--diverge-second")}, ${cssVariable("--diverge-middle")}, ${cssVariable("--diverge-first")})`,
					},
				}),
				el("span", {}, ` more on ${second.name} (4x or more at the ends)`),
			);
		} else {
			items.push(
				el("span", {}, "fewer "),
				el("span", {
					class: "ramp",
					style: {
						background: `linear-gradient(to right, ${heatStops().join(", ")})`,
					},
				}),
				el("span", {}, ` more presses (${state.scale})`),
			);
		}
		if (state.handColors) {
			for (const [kind, variable] of Object.entries(FLOW_COLORS)) {
				items.push(
					el(
						"span",
						{},
						el("span", {
							class: "swatch",
							style: { background: cssVariable(variable) },
						}),
						FLOW_LABELS[kind],
					),
				);
			}
		}
		legend.replaceChildren(...items);
	}

	function showKeyTooltip(code, event) {
		const tooltip = $("tooltip");
		const usage = model.keyUsage(selectedHosts(), state.layout, state.kinds);
		const entry = usage.keys.get(code);
		const total = [...usage.keys.values()].reduce(
			(sum, item) => sum + item.count,
			0,
		);
		const rows = entry
			? [...entry.tokens.entries()].sort((a, b) => b[1] - a[1]).slice(0, 12)
			: [];
		const header = entry
			? `${describeKey(code)}: ${formatCount(entry.count)} presses, ${percent(share(entry.count, total))}`
			: `${describeKey(code)}: unused`;
		const children = [el("strong", {}, header)];
		if (state.colorMode === "difference") {
			const [first, second] = data.hosts;
			const difference = model
				.keyDifference(first, second, state.layout, state.kinds)
				.get(code);
			if (difference) {
				children.push(
					el(
						"div",
						{},
						`${first.name} ${percent(difference.first, 2)} · ${second.name} ${percent(difference.second, 2)}`,
					),
				);
			}
		}
		if (rows.length) {
			children.push(
				el(
					"table",
					{},
					el(
						"tbody",
						{},
						rows.map(([token, count]) =>
							el(
								"tr",
								{},
								el("td", {}, tokenLabel(token)),
								el("td", {}, formatCount(count)),
							),
						),
					),
				),
			);
		}
		tooltip.replaceChildren(...children);
		tooltip.hidden = false;
		moveTooltip(event);
	}

	function moveTooltip(event) {
		const tooltip = $("tooltip");
		const offset = 16;
		const x = Math.min(
			event.clientX + offset,
			window.innerWidth - tooltip.offsetWidth - 8,
		);
		const y = Math.min(
			event.clientY + offset,
			window.innerHeight - tooltip.offsetHeight - 8,
		);
		tooltip.style.left = `${x}px`;
		tooltip.style.top = `${y}px`;
	}

	function hideTooltip() {
		$("tooltip").hidden = true;
	}

	function meter(label, value, total) {
		const ratio = share(value, total);
		return el(
			"div",
			{ class: "meter" },
			el("span", {}, label),
			el(
				"span",
				{ class: "track" },
				el("span", { class: "fill", style: { width: percent(ratio) } }),
			),
			el("span", { class: "value" }, percent(ratio)),
		);
	}

	function renderStats() {
		const hosts = selectedHosts();
		const kinds = typedKinds();
		const stats = model.layoutStats(hosts, state.layout, kinds);
		const fingerMeters = model.FINGERS.map((finger) =>
			meter(
				FINGER_LABELS[finger],
				stats.fingers.get(finger),
				stats.fingerTotal,
			),
		);
		const handTotal = stats.hands.L + stats.hands.R;
		const sections = [
			el(
				"h2",
				{},
				`${formatCount(stats.total)} tokens, ${percent(share(stats.placed, stats.total))} placed`,
			),
			el("h2", {}, "rows"),
			model.ROWS.map((row) => meter(row, stats.rows.get(row), stats.placed)),
			el("h2", {}, "hands (thumbs excluded)"),
			meter("left", stats.hands.L, handTotal),
			meter("right", stats.hands.R, handTotal),
			el("h2", {}, "fingers"),
			fingerMeters,
			el("h2", {}, "consecutive keys"),
			Object.keys(FLOW_LABELS).map((kind) =>
				meter(FLOW_LABELS[kind], stats.bigrams.get(kind), stats.bigramTotal),
			),
		];
		$("stats").replaceChildren(...sections.flat());
	}

	function renderComparison() {
		const hosts = selectedHosts();
		const kinds = typedKinds();
		const rows = data.layouts.map((layout) => {
			const stats = model.layoutStats(hosts, layout.id, kinds);
			const handTotal = stats.hands.L + stats.hands.R;
			return el(
				"tr",
				{
					class: `clickable${layout.id === state.layout ? " current" : ""}`,
					onclick: () => update({ layout: layout.id }),
				},
				el("td", {}, layout.label),
				el("td", {}, percent(share(stats.rows.get("home"), stats.placed), 0)),
				el(
					"td",
					{},
					percent(share(stats.bigrams.get("sameFinger"), stats.bigramTotal)),
				),
				el(
					"td",
					{},
					percent(share(stats.bigrams.get("alternate"), stats.bigramTotal), 0),
				),
				el("td", {}, percent(share(stats.hands.L, handTotal), 0)),
				el("td", {}, percent(share(stats.placed, stats.total), 0)),
			);
		});
		$("comparison").replaceChildren(
			el("h2", {}, "layouts"),
			el(
				"table",
				{},
				el(
					"thead",
					{},
					el(
						"tr",
						{},
						el("th", {}, "layout"),
						el(
							"th",
							{ title: "share of placed tokens on the home row" },
							"home",
						),
						el(
							"th",
							{ title: "same finger, different key, consecutive" },
							"sfb",
						),
						el("th", { title: "consecutive keys on opposite hands" }, "alt"),
						el("th", { title: "left hand share, thumbs excluded" }, "left"),
						el("th", { title: "tokens this layout can type" }, "placed"),
					),
				),
				el("tbody", {}, rows),
			),
		);
	}

	function renderUnplaced() {
		const { unplaced } = model.keyUsage(
			selectedHosts(),
			state.layout,
			state.kinds,
		);
		const entries = [...unplaced.entries()].sort((a, b) => b[1] - a[1]);
		$("unplaced").replaceChildren(
			el("h2", {}, `not on this layout (${entries.length})`),
			entries.length
				? el(
						"ul",
						{ class: "neighbours" },
						entries
							.slice(0, 30)
							.map(([token, count]) =>
								el(
									"li",
									{},
									tokenLabel(token),
									el("span", { class: "share" }, formatCount(count)),
								),
							),
					)
				: el("p", { class: "empty" }, "every token has a key"),
		);
	}

	function rankingKinds() {
		return state.tab === "shortcuts" ? new Set(["chord"]) : typedKinds();
	}

	function renderRanking() {
		const hosts = selectedHosts();
		const ranking = model.tokenRanking(hosts, rankingKinds());
		const total = ranking.reduce((sum, row) => sum + row.total, 0);
		const hostTotals = hosts.map((_, index) =>
			ranking.reduce((sum, row) => sum + row.perHost[index], 0),
		);
		const max = ranking[0]?.total ?? 0;
		const query = state.search.trim().toLowerCase();
		const visible = ranking
			.map((row, index) => ({ ...row, rank: index + 1 }))
			.filter((row) => !query || row.token.toLowerCase().includes(query))
			.slice(0, RANKING_LIMIT);
		$("token-ranking").replaceChildren(
			...visible.map((row) =>
				el(
					"li",
					{
						class: row.token === state.token ? "selected" : "",
						onclick: () => update({ token: row.token }),
					},
					el("span", { class: "rank" }, String(row.rank)),
					tokenLabel(row.token),
					el(
						"span",
						{ class: "count" },
						`${formatCount(row.total)} · ${percent(share(row.total, total))}`,
					),
					el(
						"span",
						{ class: "bar", style: { width: percent(share(row.total, max)) } },
						row.perHost
							.map((count, index) =>
								count
									? el("span", {
											title: `${hosts[index].name}: ${formatCount(count)}`,
											style: {
												flexGrow: String(count),
												background: cssVariable(
													`--host-${data.hosts.indexOf(hosts[index]) % 3}`,
												),
											},
										})
									: null,
							)
							.filter(Boolean),
					),
					hosts.length > 1
						? el(
								"span",
								{ class: "shares" },
								hosts
									.map(
										(host, index) =>
											`${host.name} ${percent(share(row.perHost[index], hostTotals[index]), 2)}`,
									)
									.join(" · "),
							)
						: null,
				),
			),
		);
	}

	function neighbourList(entries, total) {
		if (!entries.length) {
			return el("p", { class: "empty" }, "none");
		}
		return el(
			"ul",
			{ class: "neighbours" },
			entries.map(([token, count]) =>
				el(
					"li",
					{
						onclick: () => {
							if (
								token !== model.SEQUENCE_START &&
								token !== model.SEQUENCE_END
							) {
								update({ token });
							}
						},
					},
					tokenLabel(token),
					el("span", { class: "share" }, percent(share(count, total))),
					el(
						"span",
						{ class: "track" },
						el("span", { style: { width: percent(share(count, total)) } }),
					),
				),
			),
		);
	}

	function strokeDescription(token) {
		const host = selectedHosts()[0] ?? data.hosts[0];
		const strokes = host.layouts[state.layout]?.[token];
		if (!strokes) {
			return "not on this layout";
		}
		return strokes
			.map(([code, modifiers]) =>
				[modifiers, describeKey(code)].filter(Boolean).join(" + "),
			)
			.join(", then ");
	}

	function renderTokenDetail() {
		const panel = $("token-detail");
		const { token } = state;
		if (token === null) {
			panel.replaceChildren(
				el("p", { class: "empty" }, "click a token to see its neighbours"),
			);
			return;
		}
		const hosts = selectedHosts();
		const detail = model.tokenDetail(hosts, token, DETAIL_LIMIT);
		const counts = hosts.map(
			(host) => `${host.name} ${formatCount(host.unigram[token] ?? 0)}`,
		);
		panel.replaceChildren(
			el(
				"h2",
				{},
				tokenLabel(token),
				` · ${model.tokenKind(token)} · ${counts.join(" · ")}`,
			),
			el("p", { class: "empty" }, `keys: ${strokeDescription(token)}`),
			el(
				"div",
				{ class: "columns" },
				el(
					"div",
					{},
					el("h2", {}, "before"),
					neighbourList(detail.before, detail.beforeTotal),
				),
				el(
					"div",
					{},
					el("h2", {}, "after"),
					neighbourList(detail.after, detail.afterTotal),
				),
			),
			el("h2", {}, "trigrams through it"),
			el(
				"ul",
				{ class: "neighbours trigrams" },
				detail.trigrams.map(([tokens, count]) =>
					el(
						"li",
						{},
						el(
							"span",
							{},
							tokens.flatMap((item, index) => [
								index ? " " : null,
								item === token
									? el("mark", {}, tokenLabel(item))
									: tokenLabel(item),
							]),
						),
						el("span", { class: "share" }, formatCount(count)),
					),
				),
			),
		);
	}

	function render() {
		syncControls();
		if (state.tab === "board") {
			renderBoard();
			renderStats();
			renderComparison();
			renderUnplaced();
		} else {
			renderRanking();
			renderTokenDetail();
		}
	}

	readHash();
	setupControls();
	writeHash();
	render();
})();
