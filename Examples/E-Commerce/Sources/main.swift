import Foundation
import KiteWebSwift

public struct Product: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let price: Double
    public let description: String
    public let image: String
}

public struct CartItem: Codable, Sendable, Identifiable {
    public let product: Product
    public var quantity: Int

    public var id: Int { product.id }
}

public struct CartIsland: Island {
    public var islandName: String { "CartIsland" }
    public var serializedProps: String { "{}" }

    @State private var items: [CartItem] = []
    @State private var isOpen: Bool = false

    public init() {}

    public var body: HTML {
        VStack(spacing: 8) {
            Button("🛒 Cart (\(items.reduce(0) { $0 + $1.quantity }))")
                .class("px-4 py-2 bg-gray-900 text-white rounded-full font-medium hover:bg-gray-800")

            if isOpen {
                Div {
                    H3("Your Cart").style(.font(.bold), .size(.lg))
                    if items.isEmpty {
                        P("Your cart is empty.").class("text-gray-500 py-4")
                    } else {
                        ForEach(items) { item in
                            HStack {
                                Text(item.product.name).fontWeight(.medium)
                                Spacer()
                                Text("x\(item.quantity)")
                                Text("$\(String(format: "%.2f", item.product.price * Double(item.quantity)))")
                                    .fontWeight(.bold)
                            }
                        }
                    }
                }
                .padding(16)
                .backgroundColor(.white)
                .cornerRadius(12)
                .shadow(.lg)
            }
        }
    }
}

public struct StorePage: Page {
    let products = [
        Product(id: 1, name: "Swift 6 Performance Server", price: 299.00, description: "Dedicated AOT compiled hardware server instance.", image: "server.png"),
        Product(id: 2, name: "Embedded Wasm Client Pack", price: 49.00, description: "Micro-Wasm reactive runtime bundles under 40KB.", image: "wasm.png"),
        Product(id: 3, name: "Full-Stack Swift Pro License", price: 199.00, description: "Enterprise deployment toolchain and edge adapters.", image: "pro.png")
    ]

    public var body: HTML {
        Document(title: "kite-web Store") {
            HeaderView {
                HStack {
                    H1("kite-web Store").class("text-2xl font-bold")
                    Spacer()
                    CartIsland()
                }
                .container()
            }

            Main {
                H2("Featured Solutions")
                    .style(.font(.bold), .size(.xl3))
                    .class("mb-6")

                VStack(spacing: 16) {
                    ForEach(products) { prod in
                        HStack(spacing: 16) {
                            VStack(alignment: "flex-start") {
                                H3(prod.name).style(.font(.bold), .size(.xl))
                                P(prod.description).class("text-gray-600 mt-1")
                                Text("$\(String(format: "%.2f", prod.price))")
                                    .class("text-lg font-bold text-blue-600 mt-2")
                            }
                            Spacer()
                            Button("Add to Cart")
                                .class("px-4 py-2 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700")
                        }
                        .cardStyle()
                    }
                }
            }
            .container()
            .class("mt-8 mb-16")
        }
    }
}

@main
struct ECommerceApp {
    static func main() async throws {
        let app = KiteApp()
        app.registerPage("/") { _ in StorePage() }
        try await app.start(port: 3000)
    }
}
