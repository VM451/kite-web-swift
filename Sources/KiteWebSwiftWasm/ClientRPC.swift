import Foundation

/// Client RPC Transport for invoking @ServerAction endpoints from WASM Islands
public struct ClientRPC: Sendable {
    private static let lock = NSLock()
    private nonisolated(unsafe) static var _transportHandler: (@Sendable (String, [String: any Sendable]) async throws -> any Sendable)?

    public static var transportHandler: (@Sendable (String, [String: any Sendable]) async throws -> any Sendable)? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _transportHandler
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _transportHandler = newValue
        }
    }

    public static func invoke<T: Sendable>(actionName: String, params: [String: any Sendable]) async throws -> T {
        let handler = self.transportHandler
        if let handler = handler {
            let result = try await handler(actionName, params)
            if let typed = result as? T {
                return typed
            }
            throw RPCError.typeMismatch(expected: String(describing: T.self), got: String(describing: type(of: result)))
        }

        // Default implementation for browser WASM environments calling HTTP endpoints
        return try await fetchRPC(actionName: actionName, params: params)
    }

    private static func fetchRPC<T: Sendable>(actionName: String, params: [String: any Sendable]) async throws -> T {
        throw RPCError.noTransportConfigured
    }
}

public enum RPCError: Error, Sendable, CustomStringConvertible {
    case typeMismatch(expected: String, got: String)
    case serverError(String)
    case noTransportConfigured

    public var description: String {
        switch self {
        case .typeMismatch(let exp, let got):
            return "RPC Type Mismatch: Expected \(exp), got \(got)"
        case .serverError(let msg):
            return "RPC Server Error: \(msg)"
        case .noTransportConfigured:
            return "No RPC Transport Configured in Client Environment"
        }
    }
}
