import Foundation

/// React / Next.js JSX to kite-web-swift DSL AST & syntax converter
public struct ReactToSwiftMigrator: Sendable {
    public init() {}

    public func convertJSXToSwift(jsx: String) -> String {
        var swift = jsx

        let tagMappings: [(String, String)] = [
            ("div", "Div"),
            ("h1", "H1"),
            ("h2", "H2"),
            ("h3", "H3"),
            ("h4", "H4"),
            ("h5", "H5"),
            ("h6", "H6"),
            ("p", "P"),
            ("span", "Span"),
            ("section", "Section"),
            ("article", "Article"),
            ("main", "Main"),
            ("header", "HeaderView"),
            ("footer", "Footer"),
            ("form", "Form"),
            ("button", "Button")
        ]

        for (htmlTag, swiftTag) in tagMappings {
            swift = convertJSXTag(swift, htmlTag: htmlTag, swiftTag: swiftTag)
        }

        // Clean up closing tags
        swift = swift.replacingOccurrences(of: "</[a-zA-Z0-9]+>", with: "}", options: .regularExpression)

        return swift
    }

    private func convertJSXTag(_ input: String, htmlTag: String, swiftTag: String) -> String {
        var text = input
        let pattern = "<" + htmlTag + "([^>]*)>"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return input }

        let nsText = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))

        for match in matches.reversed() {
            let attrs = nsText.substring(with: match.range(at: 1))

            var modifiers = ""
            // Extract className
            let classPattern = #"className="([^"]*)""#
            if let classRegex = try? NSRegularExpression(pattern: classPattern),
               let classMatch = classRegex.firstMatch(in: attrs, range: NSRange(location: 0, length: (attrs as NSString).length)) {
                let classValue = (attrs as NSString).substring(with: classMatch.range(at: 1))
                modifiers.append(".class(\"\(classValue)\")")
            }

            // Extract id
            let idPattern = #"id="([^"]*)""#
            if let idRegex = try? NSRegularExpression(pattern: idPattern),
               let idMatch = idRegex.firstMatch(in: attrs, range: NSRange(location: 0, length: (attrs as NSString).length)) {
                let idValue = (attrs as NSString).substring(with: idMatch.range(at: 1))
                modifiers.append(".id(\"\(idValue)\")")
            }

            let replacement: String
            if modifiers.isEmpty {
                replacement = "\(swiftTag) {"
            } else {
                replacement = "\(swiftTag) {\n    \(modifiers)"
            }

            text = (text as NSString).replacingCharacters(in: match.range, with: replacement)
        }
        return text
    }
}
