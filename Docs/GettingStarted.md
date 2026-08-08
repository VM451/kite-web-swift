# Getting Started with kite-web-swift

Welcome to **kite-web-swift**, the unified full-stack web framework written in pure Swift 6.

---

## 1. Prerequisites
- **Swift 6.0+** (macOS, Ubuntu/Debian Linux, or Windows WSL2)
- Xcode 16+ on macOS or Swift 6 toolchain on Linux/Windows

---

## 2. Installation
Build and install the `kite-web-swift` CLI globally or run it via SPM:

```bash
# Clone the repository
git clone https://github.com/kite-web/kite-web-swift.git
cd kite-web-swift

# Build the CLI
swift build -c release --product kite-web-swift

# Symlink to your PATH
ln -s "$(pwd)/.build/release/kite-web-swift" /usr/local/bin/kite-web-swift
```

---

## 3. Creating Your First Project

Create a new project using the interactive scaffolder:

```bash
# Scaffold a new fullstack project
kite-web-swift new MyAwesomeApp --template fullstack

cd MyAwesomeApp
```

Available templates:
- `starter`: Lightweight single-page app with instant SSR.
- `fullstack`: Fullstack setup with SSR pages, Micro-WASM islands, and server actions.
- `api`: High-performance JSON/REST and RPC API service.

---

## 4. Local Development Server

Run the development server with live reload:

```bash
kite-web-swift dev --port 3000
```

Open `http://localhost:3000` in your browser.

---

## 5. Writing a Page

Create a type-safe page in `Sources/MyAwesomeApp/main.swift`:

```swift
import KiteWebSwift

struct BlogPostPage: Page {
    let title = "My First Swift Web Page"

    var body: HTML {
        Document(title: title) {
            HeaderView(title: "kite-web-swift")
            Main {
                H1(title)
                    .style(.font(.bold), .size(.xl3), .color(.primary600))
                P("Rendered server-side with sub-50ms TTFB.")
                    .class("text-gray-700 mt-2")
            }
            .cardStyle()
        }
    }
}
```

---

## 6. Building for Production

Compile your production server and Micro-WASM assets:

```bash
kite-web-swift build --target native --release
```

Run in production:

```bash
kite-web-swift start --port 8080
```
