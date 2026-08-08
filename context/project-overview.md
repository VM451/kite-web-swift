# Project Overview: kite-web-swift Engine

> **Vision:** A Strategy & Architecture Specification for Dethroning the JS/TS Web Stack with End-to-End Swift.

## Product Vision
kite-web-swift is designed to become the global default standard for full-stack web development. Leveraging Swift 6+ (strict data-race concurrency, Embedded Swift, result builders, and metaprogramming macros), kite-web-swift supersedes the fragmented Node.js / TypeScript / React paradigm with a unified, compile-time verified, hyper-performant, single-language framework.

## Universal Client Reality (Zero Device Constraints)
- **100% Platform-Agnostic for End-Users:** Android, Windows, Linux, Mac, iOS, ChromeOS, Smart TVs.
- **Zero Special Prerequisites:** Standard browser, standard HTML5, CSS, and standardized WebAssembly (.wasm) bytecode.
- **Progressive Enhancement:** Pure Server-Side Rendering (SSR) for instant first contentful paint (FCP < 50ms) + Micro-WASM hydration (<40KB WASM binaries).

## Key Features & Value Proposition
1. **Nominal Full-Stack Type Safety:** Compile-time verified RPC boundary with zero JSON serialization mismatch bugs.
2. **Swift Structured Concurrency:** Native multi-threaded hardware utilization with zero data races (`async/await`, `actors`, `TaskGroups`).
3. **Micro-WASM Islands Architecture:** Fast, zero-JS SSR with selective, lightweight Embedded Swift WASM client islands.
4. **Unified Toolchain:** Single Swift Package Manager (SPM) workflow replacing 10+ fragile JS configuration files.
5. **AOT + Edge Native Execution:** Native binary performance on Linux/macOS and serverless edge targets (Cloudflare Workers, AWS Lambda).

## User Flow & Core Paths
1. **Developer Path:** `kite-web-swift new my-app` -> `kite-web-swift dev` -> write `@Page` / `@Island` in Swift -> instant live reload -> `kite-web-swift build` -> deploy via Docker / Edge.
2. **End-User Path:** Visit URL -> Receive instant SSR HTML (<50ms TTFB) -> Progressive micro-WASM hydration -> 60fps reactive client interactions with Type-Safe RPC server actions.
