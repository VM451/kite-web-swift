import Foundation
import KiteWebSwiftDSL

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// KiteApp: The unified application server instance
public final class KiteApp: @unchecked Sendable {
    public let router = Router()
    private var middlewares: [Middleware] = []
    private let lock = NSLock()
    private var isRunning: Bool = false
    private var serverSocket: Int32 = -1

    public init() {
        // Default standard middleware stack
        self.middlewares = [
            LoggerMiddleware(),
            CORSMiddleware(),
            SecurityHeadersMiddleware(),
            StaticFilesMiddleware()
        ]

        // Register RPC Server Action endpoint
        registerRPCEndpoint()
    }

    public func use(_ middleware: Middleware) {
        lock.lock()
        defer { lock.unlock() }
        middlewares.append(middleware)
    }

    private func getMiddlewares() -> [Middleware] {
        lock.lock()
        defer { lock.unlock() }
        return middlewares
    }

    public func get(_ pattern: String, handler: @escaping RouteHandler) {
        router.get(pattern, handler: handler)
    }

    public func post(_ pattern: String, handler: @escaping RouteHandler) {
        router.post(pattern, handler: handler)
    }

    public func registerPage<P: Page>(_ path: String, page: @escaping @Sendable (KiteRequest) async throws -> P) {
        router.get(path) { request in
            let renderedPage = try await page(request)
            return SSRPipeline.renderHTML(renderedPage)
        }
    }

    private func registerRPCEndpoint() {
        router.post("/_kite/action/:actionName") { request in
            guard let actionName = request.pathParameters["actionName"] else {
                return KiteResponse(status: .badRequest)
            }

            var params: [String: ActionValue] = [:]
            if let parsed = try? JSONSerialization.jsonObject(with: request.body) as? [String: Any] {
                for (k, v) in parsed {
                    params[k] = ActionValue.from(any: v)
                }
            }

            do {
                let result = try await ServerActionRegistry.shared.execute(action: actionName, params: params)
                let data: Data
                if let rawData = result as? Data {
                    data = rawData
                } else if let str = result as? String {
                    data = Data(str.utf8)
                } else if JSONSerialization.isValidJSONObject(result) {
                    data = try JSONSerialization.data(withJSONObject: result)
                } else {
                    data = Data("{\"status\":\"ok\"}".utf8)
                }

                var resp = KiteResponse(status: .ok, body: data)
                resp.headers["Content-Type"] = "application/json; charset=utf-8"
                return resp
            } catch {
                let errData = Data("{\"error\":\"\(error)\"}".utf8)
                var resp = KiteResponse(status: .internalServerError, body: errData)
                resp.headers["Content-Type"] = "application/json; charset=utf-8"
                return resp
            }
        }
    }

    /// Process an incoming request through the entire middleware and routing pipeline
    public func handle(request: KiteRequest) async -> KiteResponse {
        let currentMiddlewares = getMiddlewares()

        let baseHandler: @Sendable (KiteRequest) async throws -> KiteResponse = { [weak self] req in
            guard let self = self else {
                return KiteResponse(status: .internalServerError)
            }

            if let (handler, pathParams) = self.router.resolve(request: req) {
                var populatedReq = req
                populatedReq.pathParameters = pathParams
                return try await handler(populatedReq)
            }

            var notFound = KiteResponse(status: .notFound, body: Data("404 Not Found - kite-web-swift".utf8))
            notFound.headers["Content-Type"] = "text/plain"
            return notFound
        }

        let pipeline = currentMiddlewares.reversed().reduce(baseHandler) { next, middleware in
            return { req in
                try await middleware.handle(request: req, next: next)
            }
        }

        do {
            return try await pipeline(request)
        } catch {
            var errResp = KiteResponse(status: .internalServerError, body: Data("500 Internal Server Error: \(error)".utf8))
            errResp.headers["Content-Type"] = "text/plain"
            return errResp
        }
    }

    /// Start listening on the specified host and port using non-blocking native sockets
    public func start(host: String = "0.0.0.0", port: Int = 3000) async throws {
        print("🚀 [kite-web-swift] Server starting on http://\(host == "0.0.0.0" ? "localhost" : host):\(port)")

        #if canImport(Darwin) || canImport(Glibc)
        let sock = socket(AF_INET, SOCK_STREAM, 0)
        guard sock >= 0 else {
            throw ServerError.socketCreationFailed
        }
        self.serverSocket = sock

        var opt: Int32 = 1
        setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &opt, socklen_t(MemoryLayout<Int32>.size))

        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(UInt16(port).bigEndian)
        addr.sin_addr.s_addr = in_addr_t(0) // INADDR_ANY

        let bindRes = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                bind(sock, sockPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        guard bindRes >= 0 else {
            close(sock)
            throw ServerError.bindFailed(port: port)
        }

        guard listen(sock, 128) >= 0 else {
            close(sock)
            throw ServerError.listenFailed
        }

        self.isRunning = true
        print("✨ [kite-web-swift] Ready & listening on http://localhost:\(port)")

        while isRunning {
            var clientAddr = sockaddr_in()
            var clientLen = socklen_t(MemoryLayout<sockaddr_in>.size)
            let clientSock = withUnsafeMutablePointer(to: &clientAddr) { ptr in
                ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                    accept(sock, sockPtr, &clientLen)
                }
            }

            guard clientSock >= 0 else {
                if !isRunning { break }
                continue
            }

            Task.detached { [weak self] in
                guard let self = self else {
                    close(clientSock)
                    return
                }
                await self.handleClientSocket(clientSock)
            }
        }
        #endif
    }

    private func handleClientSocket(_ clientSock: Int32) async {
        defer { close(clientSock) }

        var buffer = [UInt8](repeating: 0, count: 8192)
        let bytesRead = read(clientSock, &buffer, buffer.count)
        guard bytesRead > 0 else { return }

        let rawRequest = String(decoding: buffer[0..<bytesRead], as: UTF8.self)
        let parsedRequest = parseRawHTTP(rawRequest)

        let response = await handle(request: parsedRequest)
        let rawHTTPResponse = formatRawHTTP(response)

        rawHTTPResponse.withCString { ptr in
            let len = strlen(ptr)
            _ = write(clientSock, ptr, len)
        }
    }

    private func parseRawHTTP(_ raw: String) -> KiteRequest {
        var lines = raw.components(separatedBy: "\r\n")
        if lines.count <= 1 {
            lines = raw.components(separatedBy: "\n")
        }

        guard let firstLine = lines.first, !firstLine.isEmpty else {
            return KiteRequest(path: "/")
        }

        let parts = firstLine.split(separator: " ")
        let methodStr = parts.count > 0 ? String(parts[0]) : "GET"
        let fullPath = parts.count > 1 ? String(parts[1]) : "/"
        let method = HTTPMethod(rawValue: methodStr.uppercased()) ?? .GET

        let pathOnly: String
        var queryParams: [String: String] = [:]

        if let queryIdx = fullPath.firstIndex(of: "?") {
            pathOnly = String(fullPath[..<queryIdx])
            let queryString = String(fullPath[fullPath.index(after: queryIdx)...])
            for pair in queryString.components(separatedBy: "&") {
                let kv = pair.components(separatedBy: "=")
                if kv.count == 2 {
                    queryParams[kv[0]] = kv[1].removingPercentEncoding ?? kv[1]
                }
            }
        } else {
            pathOnly = fullPath
        }

        var headers: [String: String] = [:]
        var bodyStartIndex = lines.count

        for i in 1..<lines.count {
            let line = lines[i]
            if line.isEmpty {
                bodyStartIndex = i + 1
                break
            }
            if let colonIdx = line.firstIndex(of: ":") {
                let key = String(line[..<colonIdx]).trimmingCharacters(in: .whitespaces)
                let val = String(line[line.index(after: colonIdx)...]).trimmingCharacters(in: .whitespaces)
                headers[key] = val
            }
        }

        var bodyData = Data()
        if bodyStartIndex < lines.count {
            let bodyText = lines[bodyStartIndex..<lines.count].joined(separator: "\n")
            bodyData = Data(bodyText.utf8)
        }

        return KiteRequest(
            method: method,
            path: pathOnly,
            queryParameters: queryParams,
            headers: headers,
            body: bodyData
        )
    }

    private func formatRawHTTP(_ response: KiteResponse) -> String {
        var out = "HTTP/1.1 \(response.status.rawValue) \(response.status.reasonPhrase)\r\n"
        var finalHeaders = response.headers
        if finalHeaders["Content-Length"] == nil {
            finalHeaders["Content-Length"] = "\(response.body.count)"
        }
        if finalHeaders["Connection"] == nil {
            finalHeaders["Connection"] = "close"
        }

        for (k, v) in finalHeaders {
            out.append("\(k): \(v)\r\n")
        }
        out.append("\r\n")

        if let bodyStr = String(data: response.body, encoding: .utf8) {
            out.append(bodyStr)
        }
        return out
    }

    public func stop() {
        self.isRunning = false
        if serverSocket >= 0 {
            close(serverSocket)
            serverSocket = -1
        }
    }
}

public enum ServerError: Error, Sendable, CustomStringConvertible {
    case socketCreationFailed
    case bindFailed(port: Int)
    case listenFailed

    public var description: String {
        switch self {
        case .socketCreationFailed: return "Failed to create server socket"
        case .bindFailed(let port): return "Failed to bind socket on port \(port)"
        case .listenFailed: return "Failed to listen on server socket"
        }
    }
}
