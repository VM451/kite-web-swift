import Foundation

/// Middleware protocol for intercepting requests and responses
public protocol Middleware: Sendable {
    func handle(request: KiteRequest, next: @escaping @Sendable (KiteRequest) async throws -> KiteResponse) async throws -> KiteResponse
}

/// Logger middleware printing requests and execution durations
public struct LoggerMiddleware: Middleware {
    public init() {}

    public func handle(request: KiteRequest, next: @escaping @Sendable (KiteRequest) async throws -> KiteResponse) async throws -> KiteResponse {
        let start = Date()
        let response = try await next(request)
        let duration = Date().timeIntervalSince(start) * 1000.0
        print(String(format: "[kite-web-swift] %-6@ %@ -> %d (%.2f ms)", request.method.rawValue, request.path, response.status.rawValue, duration))
        return response
    }
}

/// CORS middleware configuring cross-origin resource sharing
public struct CORSMiddleware: Middleware {
    public var allowedOrigins: String
    public var allowedMethods: String
    public var allowedHeaders: String

    public init(
        allowedOrigins: String = "*",
        allowedMethods: String = "GET, POST, PUT, DELETE, OPTIONS, PATCH",
        allowedHeaders: String = "Content-Type, Authorization, X-Kite-Action"
    ) {
        self.allowedOrigins = allowedOrigins
        self.allowedMethods = allowedMethods
        self.allowedHeaders = allowedHeaders
    }

    public func handle(request: KiteRequest, next: @escaping @Sendable (KiteRequest) async throws -> KiteResponse) async throws -> KiteResponse {
        if request.method == .OPTIONS {
            var resp = KiteResponse(status: .noContent)
            resp.headers["Access-Control-Allow-Origin"] = allowedOrigins
            resp.headers["Access-Control-Allow-Methods"] = allowedMethods
            resp.headers["Access-Control-Allow-Headers"] = allowedHeaders
            return resp
        }

        var response = try await next(request)
        response.headers["Access-Control-Allow-Origin"] = allowedOrigins
        response.headers["Access-Control-Allow-Methods"] = allowedMethods
        response.headers["Access-Control-Allow-Headers"] = allowedHeaders
        return response
    }
}

/// Security headers middleware
public struct SecurityHeadersMiddleware: Middleware {
    public init() {}

    public func handle(request: KiteRequest, next: @escaping @Sendable (KiteRequest) async throws -> KiteResponse) async throws -> KiteResponse {
        var response = try await next(request)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        return response
    }
}

/// Static files server middleware with MIME detection
public struct StaticFilesMiddleware: Middleware {
    public let publicDirectory: String
    public let urlPrefix: String

    public init(publicDirectory: String = "public", urlPrefix: String = "/static") {
        self.publicDirectory = publicDirectory
        self.urlPrefix = urlPrefix
    }

    public func handle(request: KiteRequest, next: @escaping @Sendable (KiteRequest) async throws -> KiteResponse) async throws -> KiteResponse {
        if request.path.hasPrefix(urlPrefix) && request.method == .GET {
            let relativePath = String(request.path.dropFirst(urlPrefix.count))
            let sanitized = relativePath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            let fullPath = "\(publicDirectory)/\(sanitized)"

            if let data = try? Data(contentsOf: URL(fileURLWithPath: fullPath)) {
                var response = KiteResponse(status: .ok, body: data)
                let ext = (sanitized as NSString).pathExtension.lowercased()
                response.headers["Content-Type"] = mimeType(for: ext)
                response.headers["Cache-Control"] = "public, max-age=31536000"
                return response
            }
        }
        return try await next(request)
    }

    private func mimeType(for ext: String) -> String {
        switch ext {
        case "html", "htm": return "text/html; charset=utf-8"
        case "css": return "text/css; charset=utf-8"
        case "js", "mjs": return "application/javascript; charset=utf-8"
        case "wasm": return "application/wasm"
        case "json": return "application/json; charset=utf-8"
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "svg": return "image/svg+xml"
        case "ico": return "image/x-icon"
        default: return "application/octet-stream"
        }
    }
}
