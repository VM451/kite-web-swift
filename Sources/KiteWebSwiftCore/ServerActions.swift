import Foundation

/// Type-safe, Sendable representation of Action parameters
public enum ActionValue: Sendable, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByBooleanLiteral, Equatable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([ActionValue])
    case object([String: ActionValue])

    public init(stringLiteral value: String) {
        self = .string(value)
    }

    public init(integerLiteral value: Int) {
        self = .int(value)
    }

    public init(floatLiteral value: Double) {
        self = .double(value)
    }

    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }

    public var stringValue: String? {
        if case .string(let s) = self { return s }
        return nil
    }

    public var intValue: Int? {
        if case .int(let i) = self { return i }
        if case .double(let d) = self { return Int(d) }
        return nil
    }

    public var doubleValue: Double? {
        if case .double(let d) = self { return d }
        if case .int(let i) = self { return Double(i) }
        return nil
    }

    public var boolValue: Bool? {
        if case .bool(let b) = self { return b }
        return nil
    }

    public var objectValue: [String: ActionValue]? {
        if case .object(let o) = self { return o }
        return nil
    }

    public var arrayValue: [ActionValue]? {
        if case .array(let a) = self { return a }
        return nil
    }

    public static func from(any: Any) -> ActionValue {
        switch any {
        case let s as String:
            return .string(s)
        case let i as Int:
            return .int(i)
        case let d as Double:
            return .double(d)
        case let b as Bool:
            return .bool(b)
        case let dict as [String: Any]:
            var obj: [String: ActionValue] = [:]
            for (k, v) in dict {
                obj[k] = ActionValue.from(any: v)
            }
            return .object(obj)
        case let arr as [Any]:
            return .array(arr.map { ActionValue.from(any: $0) })
        default:
            return .null
        }
    }
}

/// Server Action RPC handler type
public typealias ServerActionHandler = @Sendable ([String: ActionValue]) async throws -> (any Sendable)

/// Global Actor Registry for Type-Safe Server Action RPC handlers
public actor ServerActionRegistry {
    public static let shared = ServerActionRegistry()

    private var handlers: [String: ServerActionHandler] = [:]

    private init() {}

    public func register(action: String, handler: @escaping ServerActionHandler) {
        handlers[action] = handler
    }

    public func execute(action: String, params: [String: ActionValue]) async throws -> any Sendable {
        guard let handler = handlers[action] else {
            throw ServerActionError.actionNotFound(action)
        }

        return try await handler(params)
    }
}

public enum ServerActionError: Error, Sendable, CustomStringConvertible {
    case actionNotFound(String)
    case invalidParameters(String)

    public var description: String {
        switch self {
        case .actionNotFound(let name):
            return "ServerAction '\(name)' not registered"
        case .invalidParameters(let reason):
            return "Invalid ServerAction parameters: \(reason)"
        }
    }
}
