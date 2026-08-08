import Foundation
import KiteWebSwiftDSL
import KiteWebSwiftCore
import KiteWebSwiftWasm

/// `@Page` attached macro that marks a struct as a routable Server-Side Rendered Page
@attached(extension, conformances: Page)
@attached(member, names: named(path))
public macro Page(_ path: String) = #externalMacro(
    module: "KiteWebSwiftMacroPlugin",
    type: "PageMacro"
)

/// `@Island` attached macro that marks a struct as an interactive WebAssembly client Island
@attached(extension, conformances: Island)
@attached(member, names: named(islandName))
public macro Island() = #externalMacro(
    module: "KiteWebSwiftMacroPlugin",
    type: "IslandMacro"
)

/// `@ServerAction` macro for generating type-safe RPC endpoints
@attached(peer, names: arbitrary)
public macro ServerAction() = #externalMacro(
    module: "KiteWebSwiftMacroPlugin",
    type: "ServerActionMacro"
)
