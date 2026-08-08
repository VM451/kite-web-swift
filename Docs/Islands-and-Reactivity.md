# Islands & Reactivity Engine

The **kite-web-swift** framework pioneers **Micro-WASM Islands**, combining instant Server-Side Rendering (SSR) with ultra-lightweight client-side WebAssembly interactivity (<40KB runtime).

---

## 1. Defining an Island (`@Island`)

Interactive components that run in the browser are declared with the `@Island` protocol/macro:

```swift
import KiteWebSwift

public struct CommentSectionIsland: Island {
    let postId: Int
    @State private var comments: [Comment]
    @State private var newCommentText: String = ""
    @State private var isSubmitting: Bool = false

    public init(postId: Int, initialComments: [Comment]) {
        self.postId = postId
        self._comments = State(initialValue: initialComments)
    }

    public var body: HTML {
        VStack(spacing: 16) {
            ForEach(comments) { comment in
                Div {
                    Text(comment.author).fontWeight(.semibold)
                    P(comment.body).class("text-gray-700 mt-1")
                }
                .padding(12)
                .backgroundColor(.gray100)
                .cornerRadius(8)
            }

            Form {
                TextArea(
                    text: newCommentText,
                    placeholder: "Add a comment..."
                )
                .class("w-full p-2 border rounded-md")

                Button(isSubmitting ? "Posting..." : "Post Comment")
                    .disabled(newCommentText.isEmpty || isSubmitting)
                    .class("px-4 py-2 bg-blue-600 text-white rounded-md")
            }
        }
    }
}
```

---

## 2. Server Actions & Type-Safe RPC

Client islands communicate with the server using type-safe Server Actions without writing any REST or GraphQL glue code:

```swift
public struct ServerActions {
    public static func postComment(postId: Int, text: String) async throws -> Comment {
        // Runs on server via RPC handler
        return try await Database.addComment(postId: postId, text: text)
    }
}
```

---

## 3. Direct DOM Signal Bindings

Unlike heavy JavaScript frameworks that reconcile huge Virtual DOM trees on every state change, **kite-web-swift** uses fine-grained Signals:
- Modifying `@State` enqueues micro-mutations in `DOMMutationQueue`.
- Only mutated elements (e.g. text nodes, classes) are updated.
- Results in 60fps silky smooth client interactions on all hardware.
