import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
///
///

// MARK: - ExpressionMacro

public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

// MARK: - DeclarationMacro

public struct StaticLetMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let argument = node.arguments.first?.expression else {
            fatalError("Wrong argument!")
        }
        return
            ["""
            struct Const {
                static let value = \(argument)
            }
            """]
    }
}

public struct ConstantMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let name = node.arguments.first?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content.text
        else {
            fatalError("compiler bug: invalid arguments")
        }
        
        let camelName = name.split(separator: "_")
            .map { String($0) }
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
        
        return ["public static var \(raw: camelName) = \(literal: name)"]
    }
}

// MARK: - PeerMacro

// MARK: - MemberMacro

public enum CustomCodable: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Extract members of the declaration
        let memberList = declaration.memberBlock.members
        // Generate CodingKeys enum cases
        let cases = memberList.compactMap({ member -> String? in
            // Check if it's a property
            guard let propertyName = member.decl.as(VariableDeclSyntax.self)?.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else {
                return nil
            }
            // Check if it has a CodableKey macro
            if let customKeyMacro = member.decl.as(VariableDeclSyntax.self)?.attributes.first(where: { element in
                element.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.description == "CodableKey"
            }) {
                // Extract value from the Macro
                let customKeyValue = customKeyMacro.as(AttributeSyntax.self)!.arguments!.as(LabeledExprListSyntax.self)!.first!.expression
                return "case \(propertyName) = \(customKeyValue)"
            } else {
                return "case \(propertyName)"
            }
        })
        // Construct CodingKeys enum
        let codingKeys: DeclSyntax = """
        enum CodingKeys: String, CodingKey {
        \(raw: cases.joined(separator: "\n"))
        }
        """
        return [codingKeys]
    }
}

public struct CustomCodingKeyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

@main
struct CustomCodablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        CustomCodable.self,
        CustomCodingKeyMacro.self,
        StaticLetMacro.self,
        ConstantMacro.self,
    ]
}
