# KiteWebSwiftDSL Guide

Declarative Swift 6 HTML5 & CSS result builder engine for type-safe UI construction.

---

## 1. Core Elements

```swift
Document(title: "Page Title") {
    HeaderView(title: "My Site")
    Main {
        Article {
            H1("Article Headline")
                .style(.font(.bold), .size(.xl3), .color(.primary600))
            P("Content goes here...")
        }
        .cardStyle()
    }
}
```

---

## 2. Layout Containers

### `VStack`
Vertical flex container:
```swift
VStack(spacing: 16) {
    Text("Top item")
    Text("Bottom item")
}
```

### `HStack`
Horizontal flex container:
```swift
HStack(spacing: 12) {
    Text("Left item")
    Spacer()
    Text("Right item")
}
```

---

## 3. Chaining Modifiers

Elements support fluid chainable styling modifiers:
- `.class("px-4 py-2 bg-blue-600 text-white")`
- `.id("submit-btn")`
- `.style(.font(.semibold), .size(.lg), .color(.primary500))`
- `.padding(16)`
- `.margin(8)`
- `.backgroundColor(.gray100)`
- `.color(.gray900)`
- `.cornerRadius(8)`
- `.shadow(.md)`
- `.disabled(isDisabled)`
- `.onClick("handleClick()")`
- `.cardStyle()`
- `.container()`

---

## 4. Collections with `ForEach`

```swift
ForEach(items) { item in
    Div {
        Text(item.title).fontWeight(.semibold)
        P(item.description)
    }
    .padding(8)
}
```
