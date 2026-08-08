# Coding Standards & Conventions

## Language & Strict Concurrency
* **Swift 6 Strict Concurrency:** All types moving across actor/thread boundaries must conform to `Sendable`.
* **Zero Force Unwraps:** Use `guard let`, `if let`, or `try #require` in tests.
* **Value Semantics:** Prefer structs for elements, models, actions, and messages. Use actors for shared state and synchronization.
* **Testing:** Use modern `import Testing` with `@Test`, `@Suite`, `#expect`, `#require`.

## DSL & Component Patterns
* Result builders must support `@resultBuilder public struct HTMLBuilder` with standard builder methods (`buildBlock`, `buildEither`, `buildOptional`, `buildArray`, `buildExpression`).
* Modifiers return `Self` or wrap in styled elements without mutating underlying state.
* SSR elements conform to `HTMLElement` / `HTMLRenderable` producing fast UTF-8 byte streams or strings.

## Error Handling
* Strongly typed errors conforming to `Error & CustomStringConvertible & Sendable`.
* HTTP status mapping for all server-side errors (`HTTPStatus`).
