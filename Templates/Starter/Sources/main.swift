import KiteWebSwift

struct HelloPage: Page {
    var body: HTML {
        Document(title: "Hello kite-web-swift") {
            HeaderView(title: "kite-web-swift")
            Main {
                H1("Dethroning the JS/TS Stack with Swift 6")
                    .style(.font(.bold), .size(.xl4), .color(.primary600))
                P("100% Type-Safe Nominal Boundaries, Native Concurrency, Instant SSR.")
                    .class("mt-4 text-gray-700")
            }
            .cardStyle()
        }
    }
}

@main
struct App {
    static func main() async throws {
        let app = KiteApp()
        app.registerPage("/") { _ in HelloPage() }
        try await app.start(port: 3000)
    }
}
