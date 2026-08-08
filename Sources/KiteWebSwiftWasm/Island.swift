import Foundation
import KiteWebSwiftDSL

/// Protocol for interactive client-side WASM Islands
public protocol Island: HTMLRenderable, Sendable {
    associatedtype Body: HTMLRenderable
    var islandName: String { get }
    var serializedProps: String { get }
    @HTMLBuilder var body: Body { get }
}

extension Island {
    public var islandName: String {
        return String(describing: Self.self)
    }

    public var serializedProps: String {
        return "{}"
    }

    public func render(into buffer: inout String) {
        // Embed island in custom HTML5 container for SSR + client hydration
        buffer.append("<kite-island data-island=\"\(HTMLEscape.escape(islandName))\"")
        if !serializedProps.isEmpty && serializedProps != "{}" {
            buffer.append(" data-props=\"\(HTMLEscape.escape(serializedProps))\"")
        }
        buffer.append(">\n")
        body.render(into: &buffer)
        buffer.append("\n</kite-island>")
    }
}

/// Global actor registry for hydrated client-side WASM islands
public actor IslandRegistry {
    public static let shared = IslandRegistry()

    private var factories: [String: @Sendable (String) -> any HTMLRenderable] = [:]

    private init() {}

    public func register<I: Island>(_ type: I.Type, factory: @escaping @Sendable (String) -> I) {
        let name = String(describing: type)
        factories[name] = { props in factory(props) }
    }

    public func instantiate(name: String, jsonProps: String) -> (any HTMLRenderable)? {
        return factories[name]?(jsonProps)
    }
}
