import Foundation

/// Base Element representation conforming to `HTMLRenderable`, `Sendable`, and `CustomStringConvertible`.
public struct Element: HTMLRenderable, Sendable, CustomStringConvertible {
    public var tag: String
    public var attributes: [String: String]
    public var styleProperties: [StyleProperty]
    public var isVoid: Bool
    public var children: [any HTMLRenderable]

    public init(
        tag: String,
        attributes: [String: String] = [:],
        styleProperties: [StyleProperty] = [],
        isVoid: Bool = false,
        children: [any HTMLRenderable] = []
    ) {
        self.tag = tag
        self.attributes = attributes
        self.styleProperties = styleProperties
        self.isVoid = isVoid
        self.children = children
    }

    public init(
        tag: String,
        attributes: [String: String] = [:],
        isVoid: Bool = false,
        @HTMLBuilder _ content: () -> HTML = { HTML.empty }
    ) {
        self.tag = tag
        self.attributes = attributes
        self.styleProperties = []
        self.isVoid = isVoid
        let rendered = content()
        if !rendered.rawHTML.isEmpty {
            self.children = [rendered]
        } else {
            self.children = []
        }
    }

    public var description: String {
        return render()
    }

    public func render(into buffer: inout String) {
        buffer.append("<")
        buffer.append(tag)

        // Merge style attributes
        var finalAttributes = attributes
        if !styleProperties.isEmpty {
            let combinedStyles = styleProperties.map(\.cssDeclaration).joined(separator: " ")
            if let existing = finalAttributes["style"] {
                finalAttributes["style"] = "\(existing) \(combinedStyles)"
            } else {
                finalAttributes["style"] = combinedStyles
            }
        }

        // Render sorted attributes for deterministic output
        for (key, val) in finalAttributes.sorted(by: { $0.key < $1.key }) {
            buffer.append(" ")
            buffer.append(key)
            if !val.isEmpty {
                buffer.append("=\"")
                buffer.append(HTMLEscape.escape(val))
                buffer.append("\"")
            }
        }

        if isVoid {
            buffer.append(" />")
            return
        }

        buffer.append(">")
        for child in children {
            child.render(into: &buffer)
        }
        buffer.append("</")
        buffer.append(tag)
        buffer.append(">")
    }
}

// MARK: - Modifiers
extension Element {
    public func `class`(_ className: String) -> Element {
        var copy = self
        if let existing = copy.attributes["class"], !existing.isEmpty {
            copy.attributes["class"] = "\(existing) \(className)"
        } else {
            copy.attributes["class"] = className
        }
        return copy
    }

    public func id(_ elementId: String) -> Element {
        var copy = self
        copy.attributes["id"] = elementId
        return copy
    }

    public func attr(_ name: String, _ value: String = "") -> Element {
        var copy = self
        copy.attributes[name] = value
        return copy
    }

    public func data(_ key: String, _ value: String) -> Element {
        return attr("data-\(key)", value)
    }

    public func style(_ properties: StyleProperty...) -> Element {
        var copy = self
        copy.styleProperties.append(contentsOf: properties)
        return copy
    }

    public func style(_ rawCSS: String) -> Element {
        var copy = self
        if let existing = copy.attributes["style"], !existing.isEmpty {
            copy.attributes["style"] = "\(existing); \(rawCSS)"
        } else {
            copy.attributes["style"] = rawCSS
        }
        return copy
    }

    public func padding(_ value: Int) -> Element {
        return style(.padding(value))
    }

    public func margin(_ value: Int) -> Element {
        return style(.margin(value))
    }

    public func backgroundColor(_ color: ColorToken) -> Element {
        return style(.backgroundColor(color))
    }

    public func color(_ color: ColorToken) -> Element {
        return style(.color(color))
    }

    public func cornerRadius(_ radius: Int) -> Element {
        return style(.borderRadius(radius))
    }

    public func fontWeight(_ weight: FontWeight) -> Element {
        return style(.font(weight))
    }

    public func fontSize(_ size: FontSize) -> Element {
        return style(.size(size))
    }

    public func shadow(_ shadow: Shadow) -> Element {
        return style(.shadow(shadow))
    }

    public func disabled(_ isDisabled: Bool = true) -> Element {
        if isDisabled {
            return attr("disabled", "disabled")
        }
        return self
    }

    public func placeholder(_ text: String) -> Element {
        return attr("placeholder", text)
    }

    public func value(_ val: String) -> Element {
        return attr("value", val)
    }

    public func href(_ url: String) -> Element {
        return attr("href", url)
    }

    public func src(_ url: String) -> Element {
        return attr("src", url)
    }

    public func alt(_ text: String) -> Element {
        return attr("alt", text)
    }

    public func target(_ value: String) -> Element {
        return attr("target", value)
    }

    public func role(_ value: String) -> Element {
        return attr("role", value)
    }

    public func ariaLabel(_ label: String) -> Element {
        return attr("aria-label", label)
    }

    public func onClick(_ jsHandler: String) -> Element {
        return attr("onclick", jsHandler)
    }

    public func onSubmit(_ jsHandler: String) -> Element {
        return attr("onsubmit", jsHandler)
    }

    public func onInput(_ jsHandler: String) -> Element {
        return attr("oninput", jsHandler)
    }
}
