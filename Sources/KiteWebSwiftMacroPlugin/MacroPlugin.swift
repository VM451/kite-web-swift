import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PageMacro: ExtensionMacro, MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let ext = try ExtensionDeclSyntax("extension \(type.trimmed): Page {}")
        return [ext]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard case .argumentList(let arguments) = node.arguments,
              let firstArg = arguments.first else {
            return []
        }
        let pathExpr = firstArg.expression
        return [
            "public static let routePath: String = \(pathExpr)"
        ]
    }
}

public struct IslandMacro: ExtensionMacro, MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let ext = try ExtensionDeclSyntax("extension \(type.trimmed): Island {}")
        return [ext]
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            return []
        }
        let name = structDecl.name.text
        return [
            "public var islandName: String { \"\(raw: name)\" }"
        ]
    }
}

public struct ServerActionMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}

@main
struct KiteWebSwiftPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PageMacro.self,
        IslandMacro.self,
        ServerActionMacro.self
    ]
}
