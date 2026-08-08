import Foundation
import Testing
import KiteWebSwiftDSL
import KiteWebSwiftCore

@Suite("KiteWebSwiftCore Server & Router Tests")
struct CoreTests {
    @Test("Router correctly matches exact and parameterized routes")
    func testRouterMatching() async throws {
        let router = Router()
        router.get("/posts/[id]") { req in
            let id = req.pathParameters["id"] ?? ""
            return KiteResponse.text("Post ID: \(id)")
        }

        let req = KiteRequest(method: .GET, path: "/posts/42")
        let resolution = router.resolve(request: req)
        #expect(resolution != nil)

        if let (handler, params) = resolution {
            var populated = req
            populated.pathParameters = params
            let resp = try await handler(populated)
            #expect(String(data: resp.body, encoding: .utf8) == "Post ID: 42")
        }
    }

    @Test("Router handles wildcard routes")
    func testRouterWildcard() async throws {
        let router = Router()
        router.get("/static/*path") { req in
            let path = req.pathParameters["path"] ?? ""
            return KiteResponse.text("Static: \(path)")
        }

        let req = KiteRequest(method: .GET, path: "/static/images/logo.png")
        let resolution = router.resolve(request: req)
        #expect(resolution != nil)

        if let (handler, params) = resolution {
            var populated = req
            populated.pathParameters = params
            let resp = try await handler(populated)
            #expect(String(data: resp.body, encoding: .utf8) == "Static: images/logo.png")
        }
    }

    @Test("Middleware pipeline executes in correct order")
    func testMiddlewarePipeline() async throws {
        let app = KiteApp()
        app.get("/hello") { _ in
            KiteResponse.text("Hello")
        }

        let req = KiteRequest(method: .GET, path: "/hello")
        let resp = await app.handle(request: req)

        #expect(resp.status == .ok)
        #expect(resp.headers["X-Content-Type-Options"] == "nosniff")
        #expect(resp.headers["Access-Control-Allow-Origin"] == "*")
        #expect(String(data: resp.body, encoding: .utf8) == "Hello")
    }

    @Test("SSR pipeline renders HTML and injects micro-WASM hydration script")
    func testSSRPipeline() {
        struct TestPage: Page {
            var body: HTML {
                Document(title: "SSR Test") {
                    H1("SSR Render")
                }
            }
        }

        let response = SSRPipeline.renderHTML(TestPage())
        let html = String(data: response.body, encoding: .utf8) ?? ""

        #expect(response.status == .ok)
        #expect(response.headers["Content-Type"] == "text/html; charset=utf-8")
        #expect(html.contains("<h1>SSR Render</h1>"))
        #expect(html.contains("kite_dom_setText"))
    }

    @Test("ServerAction registry registers and executes RPC handlers")
    func testServerActions() async throws {
        await ServerActionRegistry.shared.register(action: "calculateSum") { params in
            guard let a = params["a"]?.intValue, let b = params["b"]?.intValue else {
                throw ServerActionError.invalidParameters("Missing a or b")
            }
            return ["sum": a + b]
        }

        let res = try await ServerActionRegistry.shared.execute(action: "calculateSum", params: ["a": 10, "b": 32])
        let dict = res as? [String: Int]
        #expect(dict?["sum"] == 42)
    }
}
