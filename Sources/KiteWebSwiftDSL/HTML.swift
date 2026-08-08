import Foundation

/// A type representing a renderable HTML tree or fragment.
public struct HTML: Sendable, CustomStringConvertible, ExpressibleByStringInterpolation {
    public let rawHTML: String

    public init(_ rawHTML: String) {
        self.rawHTML = rawHTML
    }

    public init(stringLiteral value: String) {
        self.rawHTML = value
    }

    public init(_ renderable: any HTMLRenderable) {
        self.rawHTML = renderable.render()
    }

    public init(@HTMLBuilder _ content: () -> HTML) {
        self = content()
    }

    public var description: String {
        return rawHTML
    }

    public static let empty = HTML("")
}

/// Protocol for all HTML renderable items.
public protocol HTMLRenderable: Sendable {
    func render() -> String
    func render(into buffer: inout String)
}

extension HTMLRenderable {
    public func render() -> String {
        var buffer = ""
        render(into: &buffer)
        return buffer
    }
}

extension HTML: HTMLRenderable {
    public func render(into buffer: inout String) {
        buffer.append(rawHTML)
    }
}

extension String: HTMLRenderable {
    public func render(into buffer: inout String) {
        buffer.append(HTMLEscape.escape(self))
    }
}

/// Safe HTML escaping utility
public enum HTMLEscape {
    public static func escape(_ string: String) -> String {
        var result = ""
        result.reserveCapacity(string.utf8.count)
        for char in string {
            switch char {
            case "&": result.append("&amp;")
            case "<": result.append("&lt;")
            case ">": result.append("&gt;")
            case "\"": result.append("&quot;")
            case "'": result.append("&#39;")
            default: result.append(char)
            }
        }
        return result
    }
}

/// Result builder for composing HTML elements with declarative syntax.
@resultBuilder
public struct HTMLBuilder {
    public static func buildBlock(_ components: HTMLRenderable...) -> HTML {
        var buffer = ""
        for component in components {
            component.render(into: &buffer)
        }
        return HTML(buffer)
    }

    public static func buildBlock(_ components: [HTMLRenderable]) -> HTML {
        var buffer = ""
        for component in components {
            component.render(into: &buffer)
        }
        return HTML(buffer)
    }

    public static func buildExpression(_ expression: HTMLRenderable) -> HTMLRenderable {
        return expression
    }

    public static func buildExpression(_ expression: String) -> HTMLRenderable {
        return HTML(HTMLEscape.escape(expression))
    }

    public static func buildExpression(_ expression: HTML) -> HTMLRenderable {
        return expression
    }

    public static func buildOptional(_ component: HTMLRenderable?) -> HTMLRenderable {
        return component ?? HTML.empty
    }

    public static func buildEither(first component: HTMLRenderable) -> HTMLRenderable {
        return component
    }

    public static func buildEither(second component: HTMLRenderable) -> HTMLRenderable {
        return component
    }

    public static func buildArray(_ components: [HTMLRenderable]) -> HTMLRenderable {
        var buffer = ""
        for component in components {
            component.render(into: &buffer)
        }
        return HTML(buffer)
    }

    public static func buildLimitedAvailability(_ component: HTMLRenderable) -> HTMLRenderable {
        return component
    }
}
