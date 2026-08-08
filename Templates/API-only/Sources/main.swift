import Foundation
import KiteWebSwift

struct UserPayload: Codable, Sendable {
    let id: Int
    let name: String
    let email: String
}

@main
struct App {
    static func main() async throws {
        let app = KiteApp()

        app.get("/api/v1/health") { _ in
            try KiteResponse.json([
                "status": "healthy",
                "uptime": "99.999%",
                "concurrency": "Swift 6 Data-Race Free"
            ])
        }

        app.get("/api/v1/users/:id") { req in
            let userId = Int(req.pathParameters["id"] ?? "1") ?? 1
            let user = UserPayload(id: userId, name: "Swift Developer", email: "dev@kite-web.dev")
            return try KiteResponse.json(user)
        }

        app.post("/api/v1/users") { req in
            let body = try req.json(UserPayload.self)
            return try KiteResponse.json(["created": body.name, "status": "success"], status: .created)
        }

        try await app.start(port: 8080)
    }
}
