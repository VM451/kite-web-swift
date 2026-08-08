# Library & Third-Party SDK Rules

## Core Monorepo Modules
* `KiteWebSwift`: Umbrella library module re-exporting all submodules.
* `KiteWebSwiftDSL`: Declarative Swift UI-like HTML5 result builder engine.
* `KiteWebSwiftCore`: Async HTTP server, router, SSR streaming pipeline, middleware.
* `KiteWebSwiftWasm`: Micro-Wasm reactive client hydration runtime (<40KB), DOM signals, island mount.
* `KiteWebSwiftJS`: JavaScript bridge for Wasm / Web APIs (`JSObject`, `JSValue`).
* `KiteWebSwiftMacros`: Macro declarations and expansion plugin using `SwiftSyntax`.
* `KiteWebSwiftCLI`: CLI tool for project scaffolding, live reload, build pipeline, React migration, deployment.

## External Toolchains & Dependencies
* `swift-syntax` (Apple): AST inspection and code generation for Swift 6 macros.
* Web Standards: Wasm MVP + JS API standard interfaces for browser engines.
