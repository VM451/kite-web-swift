import Foundation

/// Fine-grained reactive state container for client-side Islands
@propertyWrapper
public final class State<Value: Sendable>: @unchecked Sendable {
    private var _value: Value
    private var listeners: [@Sendable (Value) -> Void] = []
    private let lock = NSLock()

    public init(wrappedValue: Value) {
        self._value = wrappedValue
    }

    public init(initialValue: Value) {
        self._value = initialValue
    }

    public var wrappedValue: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _value
        }
        set {
            lock.lock()
            _value = newValue
            let currentListeners = listeners
            lock.unlock()

            for listener in currentListeners {
                listener(newValue)
            }
        }
    }

    public var projectedValue: Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }

    public func subscribe(_ listener: @escaping @Sendable (Value) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        listeners.append(listener)
    }
}

/// Two-way state binding property wrapper
@propertyWrapper
public struct Binding<Value: Sendable>: Sendable {
    private let getter: @Sendable () -> Value
    private let setter: @Sendable (Value) -> Void

    public init(get: @escaping @Sendable () -> Value, set: @escaping @Sendable (Value) -> Void) {
        self.getter = get
        self.setter = set
    }

    public var wrappedValue: Value {
        get { getter() }
        nonmutating set { setter(newValue) }
    }

    public var projectedValue: Binding<Value> {
        self
    }

    public static func constant(_ value: Value) -> Binding<Value> {
        Binding(get: { value }, set: { _ in })
    }
}

/// Standalone reactive signal
public final class Signal<Value: Sendable>: @unchecked Sendable {
    private var _value: Value
    private var subscribers: [@Sendable (Value) -> Void] = []
    private let lock = NSLock()

    public init(_ initialValue: Value) {
        self._value = initialValue
    }

    public var value: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _value
        }
        set {
            lock.lock()
            _value = newValue
            let subs = subscribers
            lock.unlock()

            for sub in subs {
                sub(newValue)
            }
        }
    }

    public func observe(_ callback: @escaping @Sendable (Value) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        subscribers.append(callback)
    }
}
