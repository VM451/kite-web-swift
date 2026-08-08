import Testing
import KiteWebSwiftDSL
import KiteWebSwiftWasm

private final class StateBox: @unchecked Sendable {
    var value: Int = 0
}

struct SampleIsland: Island {
    var islandName: String { "SampleIsland" }
    var serializedProps: String { "{\"initial\":100}" }

    var body: HTML {
        HTML {
            Div {
                H1("Island Content")
            }
        }
    }
}

@Suite("KiteWebSwiftWasm Hydration & Reactivity Tests")
struct WasmTests {
    @Test("State wrapper notifies subscribers on value mutation")
    func testStateReactivity() {
        let state = State(wrappedValue: 10)
        let box = StateBox()

        state.subscribe { val in
            box.value = val
        }

        state.wrappedValue = 25
        #expect(box.value == 25)
        #expect(state.projectedValue.wrappedValue == 25)
    }

    @Test("Island renders with <kite-island> boundary and data attributes")
    func testIslandRendering() {
        let island = SampleIsland()
        let rendered = island.render()

        #expect(rendered.contains("<kite-island data-island=\"SampleIsland\" data-props=\"{&quot;initial&quot;:100}\">"))
        #expect(rendered.contains("<h1>Island Content</h1>"))
        #expect(rendered.contains("</kite-island>"))
    }

    @Test("DOM mutation queue buffers and flushes batched operations")
    func testDOMMutationQueue() {
        let queue = DOMMutationQueue.shared
        queue.enqueue(.setText(elementId: "heading", text: "New Title"))
        queue.enqueue(.setAttribute(elementId: "btn", name: "disabled", value: "true"))

        let flushed = queue.flush()
        #expect(flushed.count == 2)
        #expect(flushed[0] == .setText(elementId: "heading", text: "New Title"))
        #expect(flushed[1] == .setAttribute(elementId: "btn", name: "disabled", value: "true"))

        let empty = queue.flush()
        #expect(empty.isEmpty)
    }
}
