import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

#if canImport(KiteWebSwiftMacroPlugin)
import KiteWebSwiftMacroPlugin

@Suite("KiteWebSwift Macro Expansion Tests")
struct MacroTests {
    private let testMacros: [String: Macro.Type] = [
        "Page": PageMacro.self,
        "Island": IslandMacro.self
    ]

    @Test("Page macro expands routePath and Page conformance")
    func testPageMacro() {
        assertMacroExpansion(
            """
            @Page("/posts/[id]")
            struct PostView {
            }
            """,
            expandedSource: """
            struct PostView {

                public static let routePath: String = "/posts/[id]"
            }

            extension PostView: Page {
            }
            """,
            macros: testMacros
        )
    }

    @Test("Island macro expands islandName and Island conformance")
    func testIslandMacro() {
        assertMacroExpansion(
            """
            @Island
            struct CounterWidget {
            }
            """,
            expandedSource: """
            struct CounterWidget {

                public var islandName: String {
                    "CounterWidget"
                }
            }

            extension CounterWidget: Island {
            }
            """,
            macros: testMacros
        )
    }
}
#endif
