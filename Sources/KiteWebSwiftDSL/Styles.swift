import Foundation

/// Type-safe color representations
public enum ColorToken: Sendable, Equatable {
    case primary50
    case primary100
    case primary500
    case primary600
    case primary700
    case gray50
    case gray100
    case gray200
    case gray300
    case gray400
    case gray500
    case gray600
    case gray700
    case gray800
    case gray900
    case white
    case black
    case red500
    case green500
    case blue600
    case transparent
    case custom(String)

    public var cssValue: String {
        switch self {
        case .primary50: return "#eff6ff"
        case .primary100: return "#dbeafe"
        case .primary500: return "#3b82f6"
        case .primary600: return "#2563eb"
        case .primary700: return "#1d4ed8"
        case .gray50: return "#f9fafb"
        case .gray100: return "#f3f4f6"
        case .gray200: return "#e5e7eb"
        case .gray300: return "#d1d5db"
        case .gray400: return "#9ca3af"
        case .gray500: return "#6b7280"
        case .gray600: return "#4b5563"
        case .gray700: return "#374151"
        case .gray800: return "#1f2937"
        case .gray900: return "#111827"
        case .white: return "#ffffff"
        case .black: return "#000000"
        case .red500: return "#ef4444"
        case .green500: return "#10b981"
        case .blue600: return "#2563eb"
        case .transparent: return "transparent"
        case .custom(let val): return val
        }
    }
}

/// Type-safe font weight scale
public enum FontWeight: Sendable, Equatable {
    case light
    case normal
    case medium
    case semibold
    case bold
    case extrabold
    case custom(Int)

    public var cssValue: String {
        switch self {
        case .light: return "300"
        case .normal: return "400"
        case .medium: return "500"
        case .semibold: return "600"
        case .bold: return "700"
        case .extrabold: return "800"
        case .custom(let w): return "\(w)"
        }
    }
}

/// Type-safe font size scale
public enum FontSize: Sendable, Equatable {
    case xs
    case sm
    case base
    case lg
    case xl
    case xl2
    case xl3
    case xl4
    case xl5
    case custom(String)

    public var cssValue: String {
        switch self {
        case .xs: return "0.75rem"
        case .sm: return "0.875rem"
        case .base: return "1rem"
        case .lg: return "1.125rem"
        case .xl: return "1.25rem"
        case .xl2: return "1.5rem"
        case .xl3: return "1.875rem"
        case .xl4: return "2.25rem"
        case .xl5: return "3rem"
        case .custom(let s): return s
        }
    }
}

/// Type-safe shadow definitions
public enum Shadow: Sendable, Equatable {
    case sm
    case md
    case lg
    case xl
    case none
    case custom(String)

    public var cssValue: String {
        switch self {
        case .sm: return "0 1px 2px 0 rgb(0 0 0 / 0.05)"
        case .md: return "0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)"
        case .lg: return "0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)"
        case .xl: return "0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)"
        case .none: return "none"
        case .custom(let s): return s
        }
    }
}

/// Individual inline style properties
public enum StyleProperty: Sendable, Equatable {
    case font(FontWeight)
    case size(FontSize)
    case color(ColorToken)
    case backgroundColor(ColorToken)
    case padding(Int)
    case paddingHorizontal(Int)
    case paddingVertical(Int)
    case margin(Int)
    case borderRadius(Int)
    case shadow(Shadow)
    case display(String)
    case flex(String)
    case gap(Int)
    case width(String)
    case height(String)
    case maxWidth(String)
    case custom(String, String)

    public var cssDeclaration: String {
        switch self {
        case .font(let weight): return "font-weight: \(weight.cssValue);"
        case .size(let size): return "font-size: \(size.cssValue);"
        case .color(let color): return "color: \(color.cssValue);"
        case .backgroundColor(let bg): return "background-color: \(bg.cssValue);"
        case .padding(let p): return "padding: \(p)px;"
        case .paddingHorizontal(let p): return "padding-left: \(p)px; padding-right: \(p)px;"
        case .paddingVertical(let p): return "padding-top: \(p)px; padding-bottom: \(p)px;"
        case .margin(let m): return "margin: \(m)px;"
        case .borderRadius(let r): return "border-radius: \(r)px;"
        case .shadow(let s): return "box-shadow: \(s.cssValue);"
        case .display(let d): return "display: \(d);"
        case .flex(let f): return "flex: \(f);"
        case .gap(let g): return "gap: \(g)px;"
        case .width(let w): return "width: \(w);"
        case .height(let h): return "height: \(h);"
        case .maxWidth(let mw): return "max-width: \(mw);"
        case .custom(let key, let val): return "\(key): \(val);"
        }
    }
}
