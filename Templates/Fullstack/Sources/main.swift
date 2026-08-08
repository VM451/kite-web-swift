import KiteWebSwift

// Reactive Counter Island
struct CounterIsland: Island {
    var islandName: String { "CounterIsland" }
    var serializedProps: String { "{}" }

    @State private var count: Int = 0

    var body: HTML {
        VStack(spacing: 12) {
            H2("Interactive Island (<40KB WASM)")
                .style(.font(.semibold), .size(.xl))
            Text("Current count: \(count)")
                .class("text-2xl font-bold text-blue-600")
            HStack(spacing: 8) {
                Button("Increment", onClick: "window.kiteIsland?.increment()")
                    .class("px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700")
            }
        }
        .padding(16)
        .backgroundColor(.gray100)
        .cornerRadius(8)
    }
}

struct HomePage: Page {
    var body: HTML {
        Document(title: "Fullstack App - kite-web-swift") {
            HeaderView(title: "kite-web-swift Fullstack")
            Main {
                H1("Server-Side Rendering + Micro-WASM Hydration")
                    .style(.font(.bold), .size(.xl3), .color(.primary700))
                P("Static HTML stream rendered in <50ms with zero JS hydration tax.")
                    .class("mt-2 text-gray-600")
                
                Section {
                    CounterIsland()
                }
                .class("mt-8")
            }
            .cardStyle()
        }
    }
}

@main
struct App {
    static func main() async throws {
        let app = KiteApp()
        app.registerPage("/") { _ in HomePage() }
        try await app.start(port: 3000)
    }
}
