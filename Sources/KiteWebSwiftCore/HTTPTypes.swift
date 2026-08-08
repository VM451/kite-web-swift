import Foundation

/// Supported HTTP Methods
public enum HTTPMethod: String, Sendable, CaseIterable {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
    case HEAD
    case OPTIONS
}

/// HTTP Status Codes
public enum HTTPStatus: Int, Sendable {
    case ok = 200
    case created = 201
    case accepted = 202
    case noContent = 204
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case internalServerError = 500
    case badGateway = 502
    case serviceUnavailable = 503

    public var reasonPhrase: String {
        switch self {
        case .ok: return "OK"
        case .created: return "Created"
        case .accepted: return "Accepted"
        case .noContent: return "No Content"
        case .movedPermanently: return "Moved Permanently"
        case .found: return "Found"
        case .seeOther: return "See Other"
        case .badRequest: return "Bad Request"
        case .unauthorized: return "Unauthorized"
        case .forbidden: return "Forbidden"
        case .notFound: return "Not Found"
        case .methodNotAllowed: return "Method Not Allowed"
        case .internalServerError: return "Internal Server Error"
        case .badGateway: return "Bad Gateway"
        case .serviceUnavailable: return "Service Unavailable"
        }
    }
}

/// High-performance HTTP Request
public struct KiteRequest: Sendable {
    public var method: HTTPMethod
    public var path: String
    public var pathParameters: [String: String]
    public var queryParameters: [String: String]
    public var headers: [String: String]
    public var body: Data

    public init(
        method: HTTPMethod = .GET,
        path: String,
        pathParameters: [String: String] = [:],
        queryParameters: [String: String] = [:],
        headers: [String: String] = [:],
        body: Data = Data()
    ) {
        self.method = method
        self.path = path
        self.pathParameters = pathParameters
        self.queryParameters = queryParameters
        self.headers = headers
        self.body = body
    }

    public func text() -> String {
        return String(data: body, encoding: .utf8) ?? ""
    }

    public func json<T: Decodable>(_ type: T.Type) throws -> T {
        return try JSONDecoder().decode(type, from: body)
    }

    public func formData() -> [String: String] {
        guard let text = String(data: body, encoding: .utf8) else { return [:] }
        var result: [String: String] = [:]
        let pairs = text.components(separatedBy: "&")
        for pair in pairs {
            let parts = pair.components(separatedBy: "=")
            if parts.count == 2 {
                let key = parts[0].removingPercentEncoding ?? parts[0]
                let val = parts[1].removingPercentEncoding ?? parts[1]
                result[key] = val
            }
        }
        return result
    }
}

/// High-performance HTTP Response
public struct KiteResponse: Sendable {
    public var status: HTTPStatus
    public var headers: [String: String]
    public var body: Data

    public init(
        status: HTTPStatus = .ok,
        headers: [String: String] = [:],
        body: Data = Data()
    ) {
        self.status = status
        self.headers = headers
        self.body = body
    }

    public static func text(_ string: String, status: HTTPStatus = .ok) -> KiteResponse {
        var resp = KiteResponse(status: status, body: Data(string.utf8))
        resp.headers["Content-Type"] = "text/plain; charset=utf-8"
        return resp
    }

    public static func json<T: Encodable>(_ value: T, status: HTTPStatus = .ok) throws -> KiteResponse {
        let data = try JSONEncoder().encode(value)
        var resp = KiteResponse(status: status, body: data)
        resp.headers["Content-Type"] = "application/json; charset=utf-8"
        return resp
    }

    public static func redirect(to location: String, status: HTTPStatus = .seeOther) -> KiteResponse {
        var resp = KiteResponse(status: status)
        resp.headers["Location"] = location
        return resp
    }
}
