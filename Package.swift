// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "kite-web-swift",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "KiteWebSwift",
            targets: ["KiteWebSwift"]
        ),
        .library(
            name: "KiteWebSwiftDSL",
            targets: ["KiteWebSwiftDSL"]
        ),
        .library(
            name: "KiteWebSwiftCore",
            targets: ["KiteWebSwiftCore"]
        ),
        .library(
            name: "KiteWebSwiftWasm",
            targets: ["KiteWebSwiftWasm"]
        ),
        .library(
            name: "KiteWebSwiftJS",
            targets: ["KiteWebSwiftJS"]
        ),
        .library(
            name: "KiteWebSwiftMacros",
            targets: ["KiteWebSwiftMacros"]
        ),
        .executable(
            name: "kite-web-swift",
            targets: ["KiteWebSwiftCLI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0")
    ],
    targets: [
        // Umbrella Module
        .target(
            name: "KiteWebSwift",
            dependencies: [
                "KiteWebSwiftDSL",
                "KiteWebSwiftCore",
                "KiteWebSwiftWasm",
                "KiteWebSwiftJS",
                "KiteWebSwiftMacros"
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // HTML/CSS Declarative Result Builder DSL
        .target(
            name: "KiteWebSwiftDSL",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // Server Engine, Routing, Middleware & SSR
        .target(
            name: "KiteWebSwiftCore",
            dependencies: [
                "KiteWebSwiftDSL",
                "KiteWebSwiftWasm"
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // Client Hydration, Island Runtime & DOM Bridge
        .target(
            name: "KiteWebSwiftWasm",
            dependencies: [
                "KiteWebSwiftDSL"
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // JS / Web API Interop Bridge
        .target(
            name: "KiteWebSwiftJS",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // Macros Public Interface
        .target(
            name: "KiteWebSwiftMacros",
            dependencies: [
                "KiteWebSwiftMacroPlugin",
                "KiteWebSwiftDSL",
                "KiteWebSwiftCore",
                "KiteWebSwiftWasm"
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // Compiler Macro Plugin (SwiftSyntax)
        .macro(
            name: "KiteWebSwiftMacroPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
            ]
        ),

        // Command-Line Interface Tool (`kite-web-swift`)
        .executableTarget(
            name: "KiteWebSwiftCLI",
            dependencies: [
                "KiteWebSwiftCore",
                "KiteWebSwiftDSL"
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),

        // Test Targets
        .testTarget(
            name: "KiteWebSwiftDSLTests",
            dependencies: [
                "KiteWebSwiftDSL"
            ]
        ),
        .testTarget(
            name: "KiteWebSwiftCoreTests",
            dependencies: [
                "KiteWebSwiftCore",
                "KiteWebSwiftDSL"
            ]
        ),
        .testTarget(
            name: "KiteWebSwiftWasmTests",
            dependencies: [
                "KiteWebSwiftWasm",
                "KiteWebSwiftDSL"
            ]
        ),
        .testTarget(
            name: "KiteWebSwiftJSTests",
            dependencies: [
                "KiteWebSwiftJS"
            ]
        ),
        .testTarget(
            name: "KiteWebSwiftMacroTests",
            dependencies: [
                "KiteWebSwiftMacroPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "KiteWebSwiftCLITests",
            dependencies: [
                "KiteWebSwiftCLI",
                "KiteWebSwiftDSL"
            ]
        )
    ]
)
