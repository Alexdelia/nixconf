{
	type Accessor = Required<Pick<PropertyDescriptor, "get" | "set">>;
	type Handler = (this: unknown, event: BeforeUnloadEvent) => unknown;

	const findDescriptor = (
		object: object | null,
		key: PropertyKey,
	): PropertyDescriptor | undefined =>
		object === null
			? undefined
			: (Object.getOwnPropertyDescriptor(object, key) ??
				findDescriptor(Object.getPrototypeOf(object), key));

	const findAccessor = (object: object, key: PropertyKey): Accessor => {
		const descriptor = findDescriptor(object, key);
		if (descriptor?.get === undefined || descriptor.set === undefined) {
			throw new TypeError(`no native accessor for ${String(key)}`);
		}
		return { get: descriptor.get, set: descriptor.set };
	};

	const isBeforeUnload = (event: Event): event is BeforeUnloadEvent =>
		Object.prototype.toString.call(event) === "[object BeforeUnloadEvent]";

	const isHandler = (value: unknown): value is Handler =>
		typeof value === "function";

	const nativeLegacyReturnValue = findAccessor(Event.prototype, "returnValue");
	const nativeHandler = findAccessor(window, "onbeforeunload");

	const nativePreventDefault = Event.prototype.preventDefault;
	Object.defineProperty(Event.prototype, "preventDefault", {
		value: function preventDefault(this: Event) {
			if (!isBeforeUnload(this)) {
				nativePreventDefault.call(this);
			}
		},
		writable: true,
		configurable: true,
	});

	Object.defineProperty(Event.prototype, "returnValue", {
		get(this: Event): unknown {
			return nativeLegacyReturnValue.get.call(this);
		},
		set(this: Event, value: unknown) {
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

	const pageHandlerOf = new WeakMap<Handler, Handler>();

	const ignoringReturnValue = (handler: unknown): unknown => {
		if (!isHandler(handler) || pageHandlerOf.has(handler)) {
			return handler;
		}
		const silenced: Handler = function (event) {
			handler.call(this, event);
		};
		pageHandlerOf.set(silenced, handler);
		return silenced;
	};

	const getHandler = (): unknown => {
		const current: unknown = nativeHandler.get.call(window);
		return isHandler(current)
			? (pageHandlerOf.get(current) ?? current)
			: current;
	};

	const setHandler = (handler: unknown): void =>
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
			get(this: HTMLElement): unknown {
				return this.ownerDocument === document ? getHandler() : null;
			},
			set(this: HTMLElement, handler: unknown) {
				if (this.ownerDocument === document) {
					setHandler(handler);
				}
			},
			enumerable: true,
			configurable: true,
		});
	}

	const silenceNativelyInstalledHandler = (): void =>
		setHandler(nativeHandler.get.call(window));

	addEventListener("beforeunload", silenceNativelyInstalledHandler, {
		capture: true,
	});
}
