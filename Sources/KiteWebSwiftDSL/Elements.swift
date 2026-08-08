import Foundation

// MARK: - Document & Head
public struct Document: HTMLRenderable, Sendable {
    public let title: String
    public let lang: String
    public let metaCharset: String
    public let headContent: HTML
    public let bodyContent: HTML

    public init(
        title: String = "kite-web-swift",
        lang: String = "en",
        metaCharset: String = "utf-8",
        @HTMLBuilder head: () -> HTML = { HTML.empty },
        @HTMLBuilder _ body: () -> HTML
    ) {
        self.title = title
        self.lang = lang
        self.metaCharset = metaCharset
        self.headContent = head()
        self.bodyContent = body()
    }

    public func render(into buffer: inout String) {
        buffer.append("<!DOCTYPE html>\n")
        buffer.append("<html lang=\"\(HTMLEscape.escape(lang))\">\n")
        buffer.append("<head>\n")
        buffer.append("<meta charset=\"\(HTMLEscape.escape(metaCharset))\" />\n")
        buffer.append("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />\n")
        buffer.append("<title>\(HTMLEscape.escape(title))</title>\n")
        headContent.render(into: &buffer)
        buffer.append("</head>\n")
        buffer.append("<body class=\"kite-body antialiased bg-gray-50 text-gray-900 min-h-screen\">\n")
        bodyContent.render(into: &buffer)
        buffer.append("\n</body>\n</html>")
    }
}

// MARK: - Layout & Semantic Containers
public func HeaderView(title: String? = nil, @HTMLBuilder _ content: () -> HTML = { HTML.empty }) -> Element {
    Element(tag: "header", attributes: ["class": "w-full bg-white border-b border-gray-200 sticky top-0 z-50"]) {
        if let title = title {
            H1(title).class("text-xl font-bold")
        }
        content()
    }
}

public func Main(@HTMLBuilder _ content: () -> HTML) -> Element {
    Element(tag: "main", attributes: [:]) {
        content()
    }
}

public func Article(@HTMLBuilder _ content: () -> HTML) -> Element {
    Element(tag: "article", attributes: [:]) {
        content()
    }
}

public func Section(@HTMLBuilder _ content: () -> HTML) -> Element {
    Element(tag: "section", attributes: [:]) {
        content()
    }
}

public func Nav(@HTMLBuilder _ content: () -> HTML) -> Element {
    Element(tag: "nav", attributes: [:]) {
        content()
    }
}

public func Footer(@HTMLBuilder _ content: () -> HTML) -> Element {
    Element(tag: "footer", attributes: [:]) {
        content()
    }
}

public func Aside(@HTMLBuilder _ content: () -> HTML) -> Element {
    Element(tag: "aside", attributes: [:]) {
        content()
    }
}

public func Div(@HTMLBuilder _ content: () -> HTML) -> Element {
    Element(tag: "div", attributes: [:]) {
        content()
    }
}

public func Span(_ text: String = "", @HTMLBuilder _ content: () -> HTML = { HTML.empty }) -> Element {
    Element(tag: "span", attributes: [:]) {
        if !text.isEmpty {
            HTML(HTMLEscape.escape(text))
        }
        content()
    }
}

// MARK: - Typography
public func H1(_ text: String, @HTMLBuilder _ content: () -> HTML = { HTML.empty }) -> Element {
    Element(tag: "h1", attributes: [:]) {
        HTML(HTMLEscape.escape(text))
        content()
    }
}

public func H2(_ text: String, @HTMLBuilder _ content: () -> HTML = { HTML.empty }) -> Element {
    Element(tag: "h2", attributes: [:]) {
        HTML(HTMLEscape.escape(text))
        content()
    }
}

public func H3(_ text: String, @HTMLBuilder _ content: () -> HTML = { HTML.empty }) -> Element {
    Element(tag: "h3", attributes: [:]) {
        HTML(HTMLEscape.escape(text))
        content()
    }
}

public func H4(_ text: String, @HTMLBuilder _ content: () -> HTML = { HTML.empty }) -> Element {
    Element(tag: "h4", attributes: [:]) {
        HTML(HTMLEscape.escape(text))
        content()
    }
}

public func P(_ text: String = "", @HTMLBuilder _ content: () -> HTML = { HTML.empty }) -> Element {
    Element(tag: "p", attributes: [:]) {
        if !text.isEmpty {
            HTML(HTMLEscape.escape(text))
        }
        content()
    }
}

public func Text(_ text: String) -> Element {
    Element(tag: "span", attributes: [:]) {
        HTML(HTMLEscape.escape(text))
    }
}

public func A(href: String, @HTMLBuilder _ content: () -> HTML) -> Element {
    Element(tag: "a", attributes: ["href": href]) {
        content()
    }
}

public func Img(src: String, alt: String = "") -> Element {
    Element(tag: "img", attributes: ["src": src, "alt": alt], isVoid: true)
}

// MARK: - Forms & Interactive Controls
public func Form(action: String = "", method: String = "POST", @HTMLBuilder _ content: () -> HTML) -> Element {
    var attrs: [String: String] = [:]
    if !action.isEmpty { attrs["action"] = action }
    if !method.isEmpty { attrs["method"] = method }
    return Element(tag: "form", attributes: attrs) {
        content()
    }
}

public func Input(
    type: String = "text",
    name: String = "",
    value: String = "",
    placeholder: String = ""
) -> Element {
    var attrs: [String: String] = ["type": type]
    if !name.isEmpty { attrs["name"] = name }
    if !value.isEmpty { attrs["value"] = value }
    if !placeholder.isEmpty { attrs["placeholder"] = placeholder }
    return Element(tag: "input", attributes: attrs, isVoid: true)
}

public func TextArea(
    text: String = "",
    name: String = "",
    placeholder: String = ""
) -> Element {
    var attrs: [String: String] = [:]
    if !name.isEmpty { attrs["name"] = name }
    if !placeholder.isEmpty { attrs["placeholder"] = placeholder }
    return Element(tag: "textarea", attributes: attrs) {
        if !text.isEmpty {
            HTML(HTMLEscape.escape(text))
        }
    }
}

public func Button(
    _ title: String = "",
    type: String = "button",
    @HTMLBuilder _ content: () -> HTML = { HTML.empty }
) -> Element {
    Element(tag: "button", attributes: ["type": type]) {
        if !title.isEmpty {
            HTML(HTMLEscape.escape(title))
        }
        content()
    }
}

public func Button(
    _ title: String,
    onClick: String
) -> Element {
    Element(tag: "button", attributes: ["type": "button", "onclick": onClick]) {
        HTML(HTMLEscape.escape(title))
    }
}

// MARK: - Components & Special Elements
public func Spinner(size: Int = 24, color: ColorToken = .primary500) -> Element {
    Element(
        tag: "div",
        attributes: [
            "class": "kite-spinner animate-spin inline-block rounded-full border-2 border-t-transparent",
            "role": "status",
            "aria-label": "loading",
            "style": "width: \(size)px; height: \(size)px; border-color: \(color.cssValue); border-top-color: transparent;"
        ]
    )
}

public func MarkdownView(_ markdown: String) -> Element {
    let rendered = renderMarkdownToHTML(markdown)
    return Element(tag: "div", attributes: ["class": "kite-markdown prose max-w-none"]) {
        HTML(rendered)
    }
}

public func RawHTML(_ raw: String) -> HTML {
    return HTML(raw)
}

private func renderMarkdownToHTML(_ md: String) -> String {
    var out = ""
    let lines = md.components(separatedBy: "\n")
    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("### ") {
            let text = String(trimmed.dropFirst(4))
            out.append("<h3>\(HTMLEscape.escape(text))</h3>\n")
        } else if trimmed.hasPrefix("## ") {
            let text = String(trimmed.dropFirst(3))
            out.append("<h2>\(HTMLEscape.escape(text))</h2>\n")
        } else if trimmed.hasPrefix("# ") {
            let text = String(trimmed.dropFirst(2))
            out.append("<h1>\(HTMLEscape.escape(text))</h1>\n")
        } else if trimmed.hasPrefix("> ") {
            let text = String(trimmed.dropFirst(2))
            out.append("<blockquote>\(HTMLEscape.escape(text))</blockquote>\n")
        } else if trimmed.isEmpty {
            // empty line
        } else {
            out.append("<p>\(HTMLEscape.escape(trimmed))</p>\n")
        }
    }
    return out
}
