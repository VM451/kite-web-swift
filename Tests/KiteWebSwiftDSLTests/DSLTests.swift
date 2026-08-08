import Testing
import KiteWebSwiftDSL

@Suite("KiteWebSwiftDSL Tests")
struct DSLTests {
    @Test("Document rendering produces standard HTML5 doctype and metadata")
    func testDocumentRendering() {
        let doc = Document(title: "Test Page") {
            H1("Hello World")
            P("Welcome to kite-web-swift")
        }
        let rendered = doc.render()

        #expect(rendered.contains("<!DOCTYPE html>"))
        #expect(rendered.contains("<title>Test Page</title>"))
        #expect(rendered.contains("<h1>Hello World</h1>"))
        #expect(rendered.contains("<p>Welcome to kite-web-swift</p>"))
    }

    @Test("Element chaining modifiers apply classes and inline styles")
    func testElementModifiers() {
        let el = H1("Title")
            .class("font-bold text-2xl")
            .id("main-title")
            .padding(16)
            .backgroundColor(.primary500)
            .disabled()

        let rendered = el.render()
        #expect(rendered.contains("class=\"font-bold text-2xl\""))
        #expect(rendered.contains("id=\"main-title\""))
        #expect(rendered.contains("padding: 16px;"))
        #expect(rendered.contains("background-color: #3b82f6;"))
        #expect(rendered.contains("disabled=\"disabled\""))
    }

    @Test("HTML escaping safely sanitizes malicious input")
    func testHTMLEscaping() {
        let unsafeInput = "<script>alert('xss')</script> & \"quotes\""
        let p = P(unsafeInput)
        let rendered = p.render()

        #expect(!rendered.contains("<script>"))
        #expect(rendered.contains("&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt; &amp; &quot;quotes&quot;"))
    }

    @Test("Layout containers VStack and HStack generate flexbox CSS")
    func testLayoutContainers() {
        let vstack = VStack(spacing: 12) {
            Text("Item 1")
            Text("Item 2")
        }
        let rendered = vstack.render()

        #expect(rendered.contains("display: flex; flex-direction: column; gap: 12px;"))
        #expect(rendered.contains("Item 1"))
        #expect(rendered.contains("Item 2"))
    }

    @Test("ForEach builder renders collection items correctly")
    func testForEach() {
        let numbers = ["Apple", "Banana", "Cherry"]
        let list = Div {
            ForEach(numbers) { fruit in
                Span(fruit)
            }
        }
        let rendered = list.render()

        #expect(rendered.contains("<span>Apple</span>"))
        #expect(rendered.contains("<span>Banana</span>"))
        #expect(rendered.contains("<span>Cherry</span>"))
    }

    @Test("MarkdownView parses headers, quotes and paragraphs")
    func testMarkdownView() {
        let md = """
        # Heading 1
        ## Heading 2
        > A wise quote
        Paragraph text
        """
        let view = MarkdownView(md)
        let rendered = view.render()

        #expect(rendered.contains("<h1>Heading 1</h1>"))
        #expect(rendered.contains("<h2>Heading 2</h2>"))
        #expect(rendered.contains("<blockquote>A wise quote</blockquote>"))
        #expect(rendered.contains("<p>Paragraph text</p>"))
    }
}
