import Foundation

/// Representation of any JavaScript value in Swift
public enum JSValue: @unchecked Sendable, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByBooleanLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    case undefined
    case null
    case boolean(Bool)
    case number(Double)
    case string(String)
    case object(JSObject)
    case array([JSValue])
    case function(@Sendable ([JSValue]) -> JSValue)

    public init(stringLiteral value: String) {
        self = .string(value)
    }

    public init(integerLiteral value: Int) {
        self = .number(Double(value))
    }

    public init(floatLiteral value: Double) {
        self = .number(value)
    }

    public init(booleanLiteral value: Bool) {
        self = .boolean(value)
    }

    public init(arrayLiteral elements: JSValue...) {
        self = .array(elements)
    }

    public init(dictionaryLiteral elements: (String, JSValue)...) {
        let obj = JSObject()
        for (k, v) in elements {
            obj[k] = v
        }
        self = .object(obj)
    }

    public static func from(_ any: Any) -> JSValue {
        switch any {
        case let str as String:
            return .string(str)
        case let num as Double:
            return .number(num)
        case let num as Int:
            return .number(Double(num))
        case let bool as Bool:
            return .boolean(bool)
        case let dict as [String: Any]:
            let obj = JSObject()
            for (k, v) in dict {
                obj[k] = JSValue.from(v)
            }
            return .object(obj)
        case let arr as [Any]:
            return .array(arr.map { JSValue.from($0) })
        case let obj as JSObject:
            return .object(obj)
        case let val as JSValue:
            return val
        default:
            return .string(String(describing: any))
        }
    }

    public var stringValue: String? {
        if case .string(let s) = self { return s }
        return nil
    }

    public var doubleValue: Double? {
        if case .number(let n) = self { return n }
        return nil
    }

    public var boolValue: Bool? {
        if case .boolean(let b) = self { return b }
        return nil
    }

    public var objectValue: JSObject? {
        if case .object(let o) = self { return o }
        return nil
    }

    @discardableResult
    public func callMethod(_ name: String, _ args: JSValue...) -> JSValue {
        return objectValue?.callMethod(name, args) ?? .undefined
    }

    @discardableResult
    public func callMethod(_ name: String, _ args: [JSValue]) -> JSValue {
        return objectValue?.callMethod(name, args) ?? .undefined
    }
}
