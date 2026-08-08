import Foundation

/// Swift wrapper for the browser `document` API
public struct JSDocument: Sendable {
    public static func getElementById(_ id: String) -> JSObject? {
        let el = JSObject.global.document.callMethod("getElementById", .string(id))
        return el.objectValue
    }

    public static func querySelector(_ selector: String) -> JSObject? {
        let el = JSObject.global.document.callMethod("querySelector", .string(selector))
        return el.objectValue
    }

    public static func createElement(_ tag: String) -> JSObject {
        let el = JSObject.global.document.callMethod("createElement", .string(tag))
        return el.objectValue ?? JSObject()
    }
}

/// Swift wrapper for the browser `console` API
public struct JSConsole: Sendable {
    public static func log(_ items: Any...) {
        for item in items {
            print("[JS console.log]", item)
        }
    }

    public static func error(_ items: Any...) {
        for item in items {
            print("[JS console.error]", item)
        }
    }

    public static func warn(_ items: Any...) {
        for item in items {
            print("[JS console.warn]", item)
        }
    }
}

/// Swift wrapper for browser `localStorage` with mock/in-memory fallback
public struct JSLocalStorage: Sendable {
    private static let lock = NSLock()
    private nonisolated(unsafe) static var storage: [String: String] = [:]

    public static func getItem(_ key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        let jsVal = JSObject.global.localStorage.callMethod("getItem", .string(key))
        if let str = jsVal.stringValue {
            return str
        }
        return storage[key]
    }

    public static func setItem(_ key: String, _ value: String) {
        lock.lock()
        defer { lock.unlock() }
        JSObject.global.localStorage.callMethod("setItem", .string(key), .string(value))
        storage[key] = value
    }

    public static func removeItem(_ key: String) {
        lock.lock()
        defer { lock.unlock() }
        JSObject.global.localStorage.callMethod("removeItem", .string(key))
        storage.removeValue(forKey: key)
    }

    public static func clear() {
        lock.lock()
        defer { lock.unlock() }
        JSObject.global.localStorage.callMethod("clear")
        storage.removeAll()
    }
}
