import Foundation
import KiteWebSwift

// MARK: - Domain Models
public struct BlogPost: Codable, Sendable {
    public let id: Int
    public let title: String
    public let contentMarkdown: String
    public let author: String
    public let createdAt: String
}

public struct Comment: Codable, Sendable, Identifiable {
    public let id: Int
    public let author: String
    public let body: String
}

// MARK: - Mock Database Actor
public actor Database {
    private nonisolated(unsafe) static var posts: [Int: BlogPost] = [
        1: BlogPost(
            id: 1,
            title: "Why Swift 6 is the Future of Full-Stack Web Development",
            contentMarkdown: """
            # The Era of End-to-End Swift is Here
            
            Modern web development has been constrained by the JavaScript runtime tax and single-threaded event loop bottlenecks for over a decade.

            ## Key Advantages of kite-web-swift
            > Swift 6 brings compile-time strict data-race concurrency, Embedded Swift for micro-WASM (<40KB), and compile-time type safety across the entire stack.
            
            ### Zero Device Constraints
            Every browser on every device—from budget Android phones to Windows PCs—renders instant HTML in under 50ms.
            """,
            author: "kite-web Team",
            createdAt: "2026-08-09"
        )
    ]

    private nonisolated(unsafe) static var comments: [Int: [Comment]] = [
        1: [
            Comment(id: 101, author: "Alex Rivers", body: "The speed on low-end devices is unbelievable!"),
            Comment(id: 102, author: "Sarah Chen", body: "No more TypeScript / Zod glue code required.")
        ]
    ]

    public static func findPost(id: Int) async throws -> BlogPost? {
        return posts[id]
    }

    public static func fetchComments(postId: Int) async throws -> [Comment] {
        return comments[postId] ?? []
    }

    public static func addComment(postId: Int, text: String, author: String = "Community Member") async throws -> Comment {
        let newId = (comments[postId]?.count ?? 0) + 200
        let newComment = Comment(id: newId, author: author, body: text)
        if comments[postId] != nil {
            comments[postId]?.append(newComment)
        } else {
            comments[postId] = [newComment]
        }
        return newComment
    }
}

// MARK: - Server Actions
public struct ServerActions {
    public static func postComment(postId: Int, text: String) async throws -> Comment {
        return try await Database.addComment(postId: postId, text: text)
    }
}

// MARK: - Reactive Client Island (Runs in Micro-WASM on Any Browser)
public struct CommentSectionIsland: Island {
    public var islandName: String { "CommentSectionIsland" }
    public var serializedProps: String {
        guard let data = try? JSONEncoder().encode(comments) else { return "[]" }
        return String(data: data, encoding: .utf8) ?? "[]"
    }

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
                    name: "comment",
                    placeholder: "Add a comment..."
                )
                .class("w-full p-2 border rounded-md")

                Button(isSubmitting ? "Posting..." : "Post Comment")
                    .disabled(newCommentText.isEmpty || isSubmitting)
                    .class("px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 mt-2")
            }
        }
    }
}

// MARK: - Server-Side Rendered Blog Post Page (PRD Section 4.1)
public struct BlogPostPage: Page {
    public var id: Int
    @ServerState public var post: BlogPost?
    @ServerState public var comments: [Comment] = []

    public init(id: Int, post: BlogPost? = nil, comments: [Comment] = []) {
        self.id = id
        self._post = ServerState(wrappedValue: post)
        self._comments = ServerState(wrappedValue: comments)
    }

    public var body: HTML {
        Document(title: post?.title ?? "Loading...") {
            HeaderView(title: "kite-web-swift Blog")
            
            Main {
                Article {
                    if let post = post {
                        H1(post.title)
                            .style(.font(.bold), .size(.xl3), .color(.custom("#1a202c")))

                        MarkdownView(post.contentMarkdown)
                    } else {
                        Spinner()
                    }
                }
                .cardStyle()

                Section {
                    H2("Comments (\(comments.count))")
                        .style(.font(.bold), .size(.xl2))

                    // Interactive Client-Side Island (Runs on any browser/device)
                    CommentSectionIsland(postId: id, initialComments: comments)
                }
                .class("mt-8 border-t pt-4")
                .container()
            }
        }
    }
}

// MARK: - Server Entry Point
@main
struct BlogApp {
    static func main() async throws {
        // Register RPC action handler
        await ServerActionRegistry.shared.register(action: "postComment") { params in
            guard let postId = params["postId"]?.intValue,
                  let text = params["text"]?.stringValue else {
                throw ServerActionError.invalidParameters("Missing postId or text")
            }
            let comment = try await ServerActions.postComment(postId: postId, text: text)
            let data = try JSONEncoder().encode(comment)
            return data
        }

        let app = KiteApp()

        // Dynamic SSR Route: /posts/[id]
        app.get("/posts/:id") { req in
            let id = Int(req.pathParameters["id"] ?? "1") ?? 1
            let post = try await Database.findPost(id: id)
            let comments = try await Database.fetchComments(postId: id)
            let page = BlogPostPage(id: id, post: post, comments: comments)
            return SSRPipeline.renderHTML(page)
        }

        // Home redirect
        app.get("/") { _ in
            KiteResponse.redirect(to: "/posts/1")
        }

        try await app.start(port: 3000)
    }
}
