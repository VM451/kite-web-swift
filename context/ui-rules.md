# UI Styling Rules & Design System

## Layout & Semantic Guidelines
1. **Semantic HTML5 Output:** Every rendered page must output valid, semantic HTML5 tags (`<header>`, `<main>`, `<article>`, `<section>`, `<nav>`, `<footer>`).
2. **Swift DSL Declarative Modifiers:** Components are styled using chaining modifiers (`.class(...)`, `.padding(...)`, `.backgroundColor(...)`, `.cornerRadius(...)`, `.style(...)`).
3. **Island Encapsulation:** Interactive client widgets render clean fallback markup during SSR and hydrate via `<kite-island data-island="Name">`.
4. **Responsive Primitives:** Built-in flex and grid layout helpers (`VStack`, `HStack`, `ZStack`) with configurable spacing and alignment.
5. **Aesthetic Excellence:** Use curated typography, subtle borders, high contrast accessibility ratios, and smooth hover/active transitions.
