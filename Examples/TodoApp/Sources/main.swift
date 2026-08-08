import Foundation
import KiteWebSwift

public struct TodoItem: Codable, Sendable, Identifiable {
    public let id: String
    public var title: String
    public var isCompleted: Bool

    public init(id: String = UUID().uuidString, title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

public struct TodoIsland: Island {
    public var islandName: String { "TodoIsland" }
    public var serializedProps: String {
        guard let data = try? JSONEncoder().encode(items) else { return "[]" }
        return String(data: data, encoding: .utf8) ?? "[]"
    }

    @State private var items: [TodoItem]
    @State private var newTodoText: String = ""
    @State private var filter: String = "all" // all, active, completed

    public init(items: [TodoItem]) {
        self._items = State(initialValue: items)
    }

    public var body: HTML {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Input(
                    type: "text",
                    name: "title",
                    value: newTodoText,
                    placeholder: "What needs to be done?"
                )
                .class("flex-1 p-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500")

                Button("Add Task")
                    .class("px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition")
            }

            VStack(spacing: 8) {
                ForEach(items) { item in
                    HStack(spacing: 12) {
                        Input(type: "checkbox", value: item.isCompleted ? "true" : "false")
                            .class("w-5 h-5 rounded text-blue-600")

                        Text(item.title)
                            .class("flex-1 text-lg \(item.isCompleted ? "line-through text-gray-400" : "text-gray-800")")

                        Button("Delete")
                            .class("text-sm text-red-500 hover:text-red-700")
                    }
                    .padding(12)
                    .backgroundColor(.gray50)
                    .cornerRadius(6)
                }
            }

            HStack {
                Text("\(items.filter { !$0.isCompleted }.count) items left")
                    .class("text-sm text-gray-500")
                Spacer()
                HStack(spacing: 8) {
                    Button("All").class("text-sm text-blue-600 font-semibold")
                    Button("Active").class("text-sm text-gray-500 hover:text-gray-800")
                    Button("Completed").class("text-sm text-gray-500 hover:text-gray-800")
                }
            }
            .class("pt-4 border-t border-gray-200")
        }
    }
}

public struct TodoPage: Page {
    public var body: HTML {
        Document(title: "kite-web-swift Todo") {
            HeaderView(title: "kite-web-swift Todos")
            Main {
                H1("Interactive Task Manager")
                    .style(.font(.bold), .size(.xl3), .color(.primary700))
                P("Full-stack Swift with Micro-WASM Hydration.")
                    .class("text-gray-600 mt-1 mb-6")

                let initialItems = [
                    TodoItem(title: "Install kite-web-swift toolchain", isCompleted: true),
                    TodoItem(title: "Build ultra-fast WASM Islands (<40KB)", isCompleted: true),
                    TodoItem(title: "Dethrone Node.js/TypeScript stack", isCompleted: false)
                ]

                TodoIsland(items: initialItems)
            }
            .cardStyle()
        }
    }
}

@main
struct TodoApp {
    static func main() async throws {
        let app = KiteApp()
        app.registerPage("/") { _ in TodoPage() }
        try await app.start(port: 3000)
    }
}
