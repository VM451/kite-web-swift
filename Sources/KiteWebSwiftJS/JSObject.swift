import Foundation

/// JavaScript Object wrapper supporting dynamic member lookup, property access, method calls, and constructor instantiation
@dynamicMemberLookup
public final class JSObject: @unchecked Sendable, CustomStringConvertible {
    private var storage: [String: JSValue] = [:]
    private var constructorHandler: (@Sendable ([JSValue]) -> JSObject)?
    private let lock = NSLock()

    public init(storage: [String: JSValue] = [:]) {
        self.storage = storage
    }

    public static let global: JSObject = {
        let g = JSObject()
        g["window"] = .object(g)
        g["document"] = .object(JSObject())
        g["console"] = .object(JSObject())
        return g
    }()

    public subscript(key: String) -> JSValue {
        get {
            lock.lock()
            defer { lock.unlock() }
            return storage[key] ?? .undefined
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            storage[key] = newValue
        }
    }

    public subscript(dynamicMember member: String) -> JSObject {
        get {
            lock.lock()
            defer { lock.unlock() }
            if let existing = storage[member]?.objectValue {
                return existing
            }
            let newObj = JSObject()
            storage[member] = .object(newObj)
            return newObj
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            storage[member] = .object(newValue)
        }
    }

    public func setConstructor(_ handler: @escaping @Sendable ([JSValue]) -> JSObject) {
        lock.lock()
        defer { lock.unlock() }
        self.constructorHandler = handler
    }

    @discardableResult
    public func fromConstructor(_ arguments: JSValue...) -> JSObject {
        return fromConstructor(arguments)
    }

    @discardableResult
    public func fromConstructor(_ arguments: [JSValue]) -> JSObject {
        lock.lock()
        let handler = self.constructorHandler
        lock.unlock()

        if let handler = handler {
            return handler(arguments)
        }

        // Default: return a new instance with arguments recorded
        let instance = JSObject()
        instance["__arguments"] = .array(arguments)
        instance["__prototype"] = .object(self)
        return instance
    }

    @discardableResult
    public func callMethod(_ name: String, _ args: JSValue...) -> JSValue {
        return callMethod(name, args)
    }

    @discardableResult
    public func callMethod(_ name: String, _ args: [JSValue]) -> JSValue {
        let val = self[name]
        if case .function(let fn) = val {
            return fn(args)
        }
        return .undefined
    }

    public var description: String {
        lock.lock()
        defer { lock.unlock() }
        return "JSObject(\(storage))"
    }
}
