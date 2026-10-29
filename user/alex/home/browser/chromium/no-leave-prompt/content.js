{
	const findDescriptor = (object, key) =>
		object &&
		(Object.getOwnPropertyDescriptor(object, key) ??
			findDescriptor(Object.getPrototypeOf(object), key));

	const isBeforeUnload = (event) =>
		Object.prototype.toString.call(event) === "[object BeforeUnloadEvent]";

	const nativePreventDefault = Event.prototype.preventDefault;
	Object.defineProperty(Event.prototype, "preventDefault", {
		value: function preventDefault() {
			if (!isBeforeUnload(this)) {
				nativePreventDefault.call(this);
			}
		},
		writable: true,
		configurable: true,
	});

	const nativeLegacyReturnValue = findDescriptor(
		Event.prototype,
		"returnValue",
	);
	Object.defineProperty(Event.prototype, "returnValue", {
		get() {
			return nativeLegacyReturnValue.get.call(this);
		},
		set(value) {
			if (!isBeforeUnload(this)) {
				nativeLegacyReturnValue.set.call(this, value);
			}
		},
		enumerable: true,
		configurable: true,
	});

	Object.defineProperty(BeforeUnloadEvent.prototype, "returnValue", {
		get: () => "",
		set() {},
		enumerable: true,
		configurable: true,
	});

	const nativeHandler = findDescriptor(window, "onbeforeunload");
	const pageHandlerOf = new WeakMap();

	const ignoringReturnValue = (handler) => {
		if (typeof handler !== "function" || pageHandlerOf.has(handler)) {
			return handler;
		}
		const silenced = function (event) {
			handler.call(this, event);
		};
		pageHandlerOf.set(silenced, handler);
		return silenced;
	};

	const getHandler = () => {
		const current = nativeHandler.get.call(window);
		return pageHandlerOf.get(current) ?? current;
	};

	const setHandler = (handler) =>
		nativeHandler.set.call(window, ignoringReturnValue(handler));

	Object.defineProperty(window, "onbeforeunload", {
		get: getHandler,
		set: setHandler,
		enumerable: true,
		configurable: true,
	});

	for (const element of [
		HTMLBodyElement.prototype,
		HTMLFrameSetElement.prototype,
	]) {
		Object.defineProperty(element, "onbeforeunload", {
			get() {
				return this.ownerDocument === document ? getHandler() : null;
			},
			set(handler) {
				if (this.ownerDocument === document) {
					setHandler(handler);
				}
			},
			enumerable: true,
			configurable: true,
		});
	}

	const silenceNativelyInstalledHandler = () =>
		setHandler(nativeHandler.get.call(window));

	addEventListener("beforeunload", silenceNativelyInstalledHandler, {
		capture: true,
	});
}
