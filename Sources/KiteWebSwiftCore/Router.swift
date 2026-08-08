import Foundation
import KiteWebSwiftDSL

/// Route Handler function type
public typealias RouteHandler = @Sendable (KiteRequest) async throws -> KiteResponse

/// Single registered route pattern
public struct Route: Sendable {
    public let method: HTTPMethod
    public let pattern: String
    public let segments: [RouteSegment]
    public let handler: RouteHandler

    public init(method: HTTPMethod, pattern: String, handler: @escaping RouteHandler) {
        self.method = method
        self.pattern = pattern
        self.segments = Route.parsePattern(pattern)
        self.handler = handler
    }

    public static func parsePattern(_ pattern: String) -> [RouteSegment] {
        let cleaned = pattern.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        if cleaned.isEmpty { return [] }
        return cleaned.components(separatedBy: "/").map { seg in
            if seg.hasPrefix("[") && seg.hasSuffix("]") {
                let paramName = String(seg.dropFirst().dropLast())
                return .parameter(paramName)
            } else if seg.hasPrefix(":") {
                let paramName = String(seg.dropFirst())
                return .parameter(paramName)
            } else if seg == "*" || seg.hasPrefix("*") {
                let wildcardName = seg.hasPrefix("*") ? String(seg.dropFirst()) : "wildcard"
                return .wildcard(wildcardName.isEmpty ? "wildcard" : wildcardName)
            } else {
                return .exact(seg)
            }
        }
    }

    public func match(method reqMethod: HTTPMethod, path reqPath: String) -> [String: String]? {
        if self.method != reqMethod { return nil }

        let cleaned = reqPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let parts = cleaned.isEmpty ? [] : cleaned.components(separatedBy: "/")

        var params: [String: String] = [:]
        var partIdx = 0

        for segIdx in 0..<segments.count {
            let seg = segments[segIdx]
            switch seg {
            case .exact(let text):
                guard partIdx < parts.count, parts[partIdx] == text else { return nil }
                partIdx += 1
            case .parameter(let name):
                guard partIdx < parts.count else { return nil }
                params[name] = parts[partIdx]
                partIdx += 1
            case .wildcard(let name):
                let remainder = parts[partIdx..<parts.count].joined(separator: "/")
                params[name] = remainder
                return params
            }
        }

        if partIdx == parts.count {
            return params
        }
        return nil
    }
}

public enum RouteSegment: Sendable {
    case exact(String)
    case parameter(String)
    case wildcard(String)
}

/// Dynamic Router with Trie matching and route registration
public final class Router: @unchecked Sendable {
    private var routes: [Route] = []
    private let lock = NSLock()

    public init() {}

    public func add(method: HTTPMethod, pattern: String, handler: @escaping RouteHandler) {
        lock.lock()
        defer { lock.unlock() }
        routes.append(Route(method: method, pattern: pattern, handler: handler))
    }

    public func get(_ pattern: String, handler: @escaping RouteHandler) {
        add(method: .GET, pattern: pattern, handler: handler)
    }

    public func post(_ pattern: String, handler: @escaping RouteHandler) {
        add(method: .POST, pattern: pattern, handler: handler)
    }

    public func put(_ pattern: String, handler: @escaping RouteHandler) {
        add(method: .PUT, pattern: pattern, handler: handler)
    }

    public func delete(_ pattern: String, handler: @escaping RouteHandler) {
        add(method: .DELETE, pattern: pattern, handler: handler)
    }

    public func patch(_ pattern: String, handler: @escaping RouteHandler) {
        add(method: .PATCH, pattern: pattern, handler: handler)
    }

    public func resolve(request: KiteRequest) -> (RouteHandler, [String: String])? {
        lock.lock()
        let currentRoutes = routes
        lock.unlock()

        for route in currentRoutes {
            if let params = route.match(method: request.method, path: request.path) {
                return (route.handler, params)
            }
        }
        return nil
    }
}
