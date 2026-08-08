// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BlogExample",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(name: "kite-web-swift", path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "BlogExample",
            dependencies: [
                .product(name: "KiteWebSwift", package: "kite-web-swift")
            ]
        )
    ]
)
