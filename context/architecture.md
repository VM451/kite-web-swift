# System Architecture

## Tech Stack
* **Language & Toolchain:** Swift 6.0+ with strict concurrency (`-strict-concurrency=complete`), Swift Package Manager.
* **Server Engine:** `KiteWebSwiftCore` with non-blocking HTTP server, structured concurrency, route trie/matcher, middleware pipeline, SSR HTML renderer.
* **DSL & UI Layer:** `KiteWebSwiftDSL` HTML5 result builder (`@HTMLBuilder`), type-safe attributes, CSS and utility styling modifiers.
* **Client WASM Engine:** `KiteWebSwiftWasm` micro-reactive signal engine, island hydration container, DOM event delegation, batch DOM mutation queue.
* **Macros:** `KiteWebSwiftMacros` / `KiteWebSwiftMacroPlugin` using SwiftSyntax (`@Page`, `@Island`, `@ServerAction`, `@PathParameter`, `@ServerState`).
* **JS Interop:** `KiteWebSwiftJS` standard dynamic JS bridging (`JSObject`, `JSValue`, Web APIs).
* **CLI Engine:** `KiteWebSwiftCLI` (`kite-web-swift dev/build/start/new/migrate/deploy`).
* **Deployment Targets:** Linux AOT Binary (Docker <25MB), macOS, Cloudflare Workers WASI, AWS Lambda.

## Monorepo Folder Structure & Boundaries
```text
kite-web-swift/
├── Package.swift               # SPM Manifest with Swift 6 targets
├── AGENTS.md                   # Agent execution protocol
├── context/                    # Context files (Architecture, UI, Tracker, etc.)
├── Sources/
│   ├── KiteWebSwift/           # Umbrella library module
│   ├── KiteWebSwiftDSL/        # Result Builders, HTML Elements, Type-safe Styling
│   ├── KiteWebSwiftCore/       # HTTP Server, Router, Middleware, SSR Engine
│   ├── KiteWebSwiftWasm/       # Client Hydration, Island Runtime, DOM Bridge
│   ├── KiteWebSwiftMacros/     # Public Macro attributes & interfaces
│   ├── KiteWebSwiftMacroPlugin/# SwiftSyntax Macro Implementations
│   ├── KiteWebSwiftJS/         # Web/DOM JS interoperability bridge
│   └── KiteWebSwiftCLI/        # Unified Developer CLI Tool
├── Templates/                  # Starter, Fullstack, API-only templates
├── Examples/                   # Blog, TodoApp, E-Commerce sample apps
├── Docs/                       # Documentation, PRD, Benchmarks, Architecture
├── Tests/                      # Swift Testing test targets
├── Dockerfile                  # Multi-stage Linux Docker build
└── docker-compose.yml          # Containerized development orchestrator
```

## Architecture Invariants
1. **Zero-JSON RPC Boundary:** Client-server RPC calls are statically typed through `@ServerAction` code generation and nominal types.
2. **Micro-Bundle Footprint:** Client islands compile to micro-WASM (<40KB) without monolithic virtual DOM or heavy JS runtimes.
3. **Strict Data-Race Safety:** 100% thread safety across server request handling via Swift 6 structured concurrency and Sendable checks.
4. **Islands Separation:** Static HTML is rendered on the server; interactivity is isolated in `<kite-island>` tags.
