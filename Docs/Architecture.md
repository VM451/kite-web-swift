# System Architecture & Technical Specification

## Overview
**kite-web-swift** replaces the traditional multi-tier JavaScript web stack with a unified Swift 6 architecture.

---

## 1. Swift 6 Concurrency & Actor Safety
Every request in `KiteWebSwiftCore` runs within Swift's structured concurrency model:
- **Zero Data Races:** All shared registries (`ServerActionRegistry`, `IslandRegistry`) are implemented as Swift `actor`s or protected by synchronized concurrency barriers.
- **Hardware Thread Scaling:** Swift utilizes hardware worker threads without the single-threaded event loop blocking bottlenecks of Node.js.

---

## 2. Server-Side Rendering (SSR) & Streaming Pipeline
1. **Route Resolution:** High-speed trie matching extracts path parameters (`/posts/[id]` or `/posts/:id`) and wildcards (`/static/*path`).
2. **Data Fetching:** Async `@ServerState` data loader executes asynchronously.
3. **HTML Result Builder Generation:** `@HTMLBuilder` constructs an optimized UTF-8 byte stream with zero intermediate DOM allocations.
4. **Micro-Hydration Injection:** Automatically attaches `<kite-island>` hydration hooks and progressive enhancement scripts before streaming the response to the browser.

---

## 3. Micro-WASM Client Islands Engine
- **Bundle Size:** < 40KB gzipped WebAssembly binary.
- **Direct Signal Bindings:** `@State` and `@Binding` mutate DOM elements directly through a batched C-ABI mutation queue (`DOMMutationQueue`), avoiding expensive Virtual DOM full-tree reconciliation passes.
- **Universal Compatibility:** Standard WebAssembly standard bytecode executed by Chrome (V8), Safari (JavaScriptCore), Edge, Firefox (SpiderMonkey), and Samsung Internet.

---

## 4. JS/NPM Interoperability Layer (`KiteWebSwiftJS`)
When integrating with existing JavaScript libraries (like Chart.js or Three.js), `KiteWebSwiftJS` provides dynamic member lookup and constructor bridges:

```swift
import KiteWebSwiftJS

let chart = JSObject.global.Chart.fromConstructor(
    canvasElement,
    JSValue.from(["type": "line", "data": chartData])
)
```
