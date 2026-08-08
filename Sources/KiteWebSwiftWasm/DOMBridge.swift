import Foundation

/// DOM mutation operations for micro-WASM hydration
public enum DOMMutation: Sendable, Equatable {
    case setText(elementId: String, text: String)
    case setAttribute(elementId: String, name: String, value: String)
    case removeAttribute(elementId: String, name: String)
    case appendChild(parentId: String, html: String)
    case removeChild(parentId: String, childId: String)
    case replaceContent(elementId: String, html: String)
}

/// Batch DOM mutation queue minimizing JS/WASM boundary crossing
public final class DOMMutationQueue: @unchecked Sendable {
    public static let shared = DOMMutationQueue()

    private var pendingMutations: [DOMMutation] = []
    private let lock = NSLock()

    private init() {}

    public func enqueue(_ mutation: DOMMutation) {
        lock.lock()
        defer { lock.unlock() }
        pendingMutations.append(mutation)
    }

    public func flush() -> [DOMMutation] {
        lock.lock()
        defer { lock.unlock() }
        let batch = pendingMutations
        pendingMutations.removeAll()
        return batch
    }
}

/// Client-side event dispatcher for WASM hydration
public final class DOMEventDispatcher: @unchecked Sendable {
    public static let shared = DOMEventDispatcher()

    private var handlers: [String: @Sendable (String) -> Void] = [:]
    private let lock = NSLock()

    private init() {}

    public func registerHandler(for elementId: String, event: String, handler: @escaping @Sendable (String) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        let key = "\(elementId):\(event)"
        handlers[key] = handler
    }

    public func dispatch(elementId: String, event: String, eventData: String) {
        let key = "\(elementId):\(event)"
        let handler: (@Sendable (String) -> Void)?
        lock.lock()
        handler = handlers[key]
        lock.unlock()

        handler?(eventData)
    }
}
