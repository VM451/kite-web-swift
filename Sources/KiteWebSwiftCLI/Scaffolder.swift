import Foundation

/// Project scaffolder for `kite-web-swift new`
public struct ProjectScaffolder: Sendable {
    public init() {}

    public func scaffold(projectName: String, template: String, targetDirectory: String) throws {
        let root = URL(fileURLWithPath: targetDirectory).appendingPathComponent(projectName)
        let fm = FileManager.default

        try fm.createDirectory(at: root, withIntermediateDirectories: true)
        try fm.createDirectory(at: root.appendingPathComponent("Sources"), withIntermediateDirectories: true)
        try fm.createDirectory(at: root.appendingPathComponent("Sources/\(projectName)"), withIntermediateDirectories: true)
        try fm.createDirectory(at: root.appendingPathComponent("public"), withIntermediateDirectories: true)

        let packageSwift = """
        // swift-tools-version: 6.0
        import PackageDescription

        let package = Package(
            name: "\(projectName)",
            platforms: [.macOS(.v14)],
            dependencies: [
                .package(url: "https://github.com/kite-web/kite-web-swift.git", from: "1.0.0")
            ],
            targets: [
                .executableTarget(
                    name: "\(projectName)",
                    dependencies: [
                        .product(name: "KiteWebSwift", package: "kite-web-swift")
                    ]
                )
            ]
        )
        """
        try packageSwift.write(to: root.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8)

        let mainSwift: String
        switch template.lowercased() {
        case "api":
            mainSwift = """
            import KiteWebSwift

            @main
            struct App {
                static func main() async throws {
                    let app = KiteApp()
                    app.get("/api/health") { _ in
                        try KiteResponse.json(["status": "healthy", "version": "1.0.0"])
                    }
                    try await app.start(port: 3000)
                }
            }
            """
        case "fullstack":
            mainSwift = """
            import KiteWebSwift

            struct HomePage: Page {
                var body: HTML {
                    Document(title: "\(projectName) - Fullstack") {
                        HeaderView(title: "\(projectName)")
                        Main {
                            H1("Welcome to kite-web-swift")
                                .style(.font(.bold), .size(.xl3), .color(.primary600))
                            P("Instant SSR with Micro-WASM Hydration.")
                        }
                        .container()
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
            """
        default: // starter
            mainSwift = """
            import KiteWebSwift

            struct WelcomePage: Page {
                var body: HTML {
                    Document(title: "Hello \(projectName)") {
                        Main {
                            H1("🚀 Powered by kite-web-swift")
                                .style(.font(.bold), .size(.xl4), .color(.primary500))
                            P("Zero JS bloat, 100% Type-Safe Swift on Server & Client.")
                                .class("text-gray-700 mt-4")
                        }
                        .cardStyle()
                    }
                }
            }

            @main
            struct App {
                static func main() async throws {
                    let app = KiteApp()
                    app.registerPage("/") { _ in WelcomePage() }
                    try await app.start(port: 3000)
                }
            }
            """
        }

        try mainSwift.write(to: root.appendingPathComponent("Sources/\(projectName)/main.swift"), atomically: true, encoding: .utf8)
        print("✨ Successfully scaffolded '\(projectName)' using '\(template)' template in \(root.path)")
    }
}
