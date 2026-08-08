import Testing
import KiteWebSwiftJS

@Suite("KiteWebSwiftJS Interoperability Tests")
struct JSTests {
    @Test("JSValue literals and conversions function accurately")
    func testJSValueTypes() {
        let str: JSValue = "hello"
        let num: JSValue = 42
        let bool: JSValue = true

        #expect(str.stringValue == "hello")
        #expect(num.doubleValue == 42.0)
        #expect(bool.boolValue == true)
    }

    @Test("JSObject dynamicMemberLookup and constructor invocation")
    func testJSObjectDynamicMemberLookup() {
        let global = JSObject.global
        global.Chart.setConstructor { args in
            let instance = JSObject()
            instance["type"] = args.first ?? "bar"
            return instance
        }

        let chart = global.Chart.fromConstructor("line")
        #expect(chart["type"].stringValue == "line")
    }

    @Test("JSLocalStorage store and retrieve simulation")
    func testJSLocalStorage() {
        JSLocalStorage.setItem("theme", "dark")
        #expect(JSLocalStorage.getItem("theme") == "dark")
    }
}
