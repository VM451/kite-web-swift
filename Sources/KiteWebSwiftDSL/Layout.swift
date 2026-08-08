import Foundation

/// Vertical Stack container with flexbox layout
public func VStack(
    spacing: Int = 8,
    alignment: String = "stretch",
    @HTMLBuilder _ content: () -> HTML
) -> Element {
    Element(
        tag: "div",
        attributes: [
            "class": "kite-vstack flex flex-col",
            "style": "display: flex; flex-direction: column; gap: \(spacing)px; align-items: \(alignment);"
        ]
    ) {
        content()
    }
}

/// Horizontal Stack container with flexbox layout
public func HStack(
    spacing: Int = 8,
    alignment: String = "center",
    @HTMLBuilder _ content: () -> HTML
) -> Element {
    Element(
        tag: "div",
        attributes: [
            "class": "kite-hstack flex flex-row",
            "style": "display: flex; flex-direction: row; gap: \(spacing)px; align-items: \(alignment);"
        ]
    ) {
        content()
    }
}

/// Overlapping Stack container (relative/absolute positioning)
public func ZStack(
    @HTMLBuilder _ content: () -> HTML
) -> Element {
    Element(
        tag: "div",
        attributes: [
            "class": "kite-zstack relative",
            "style": "position: relative; display: grid;"
        ]
    ) {
        content()
    }
}

/// Flexible space filler in flex layouts
public func Spacer() -> Element {
    Element(
        tag: "div",
        attributes: [
            "class": "kite-spacer flex-1",
            "style": "flex: 1 1 0%;"
        ]
    )
}

/// Declarative collection renderer
public struct ForEach<Data: Sequence & Sendable, Content: HTMLRenderable>: HTMLRenderable where Data.Element: Sendable {
    public let data: Data
    public let content: @Sendable (Data.Element) -> Content

    public init(_ data: Data, @HTMLBuilder content: @escaping @Sendable (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

    public func render(into buffer: inout String) {
        for item in data {
            let rendered = content(item)
            rendered.render(into: &buffer)
        }
    }
}

// MARK: - Responsive Utilities & Style Extensions
extension Element {
    /// PRD Section 4.3 responsive card helper
    public func cardStyle() -> Element {
        self.class("w-full max-w-4xl mx-auto bg-white shadow-md rounded-lg p-4 md:p-8 border border-gray-200")
            .style("margin-left: auto; margin-right: auto; background-color: #ffffff; border-radius: 8px; box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1); border: 1px solid #e5e7eb; padding: 24px;")
    }

    /// Center container helper
    public func container(maxWidth: String = "1200px") -> Element {
        self.class("mx-auto px-4 w-full")
            .style("max-width: \(maxWidth); margin-left: auto; margin-right: auto; padding-left: 16px; padding-right: 16px;")
    }
}
