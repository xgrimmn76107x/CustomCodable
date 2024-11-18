import Foundation
import SwiftCompilerPlugin
import SwiftDiagnostics
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

public enum URLMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression,
              let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
              segments.count == 1,
              case .stringSegment(let literalSegment)? = segments.first
        else {
            throw CustomError.message("#URL requires a static string literal")
        }
        guard let _ = URL(string: literalSegment.content.text) else {
            throw CustomError.message("malformed url: \(argument)")
        }
        return "URL(string: \(argument))!"
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

public struct AddCompletionHandlerMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let functionDecl = declaration.as(FunctionDeclSyntax.self) else {
            context.diagnose(AddCompletionMacroDiagnostic.requiresFunction.diagnose(at: node))
            return []
        }

        guard functionDecl.signature.parameterClause.parameters.count == 0,
              let _ = functionDecl.signature.effectSpecifiers?.asyncSpecifier,
              let returnTypeSyntax = functionDecl.signature.returnClause?.type.as(IdentifierTypeSyntax.self)?.name.text else {
            context.diagnose(AddCompletionMacroDiagnostic.noReturn.diagnose(at: node))
            return []
        }

        let functionName = functionDecl.name.text

        print(functionDecl.attributes)

        return [DeclSyntax(stringLiteral: """
        func \(functionName)(onCompletion: @escaping @Sendable (\(returnTypeSyntax)) -> Void) {
            Task.detached {
                onCompletion(await \(functionName)())
            }
        }
        """)]
    }
}

// MARK: - Accessor

public struct DictionaryStoragePropertyMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        // Extract information from the stored property declaration
        guard let variableDecl = declaration.as(VariableDeclSyntax.self),
              let patternBinding = variableDecl.bindings.first,
              var identifier = patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
              let identifierType = patternBinding.typeAnnotation?.type.as(IdentifierTypeSyntax.self)?.name.text else {
            return []
        }
        // Extract custom key from macro argument if provided
        if let attributeSyntax = variableDecl.attributes.first?.as(AttributeSyntax.self),
           let argument = attributeSyntax.arguments?.as(LabeledExprListSyntax.self)?.first,
           let key = argument.expression.as(StringLiteralExprSyntax.self)?.segments.first?.as(StringSegmentSyntax.self)?.content.text {
            identifier = key
        }
        // Generate custom accessors for the stored property
        return [
            AccessorDeclSyntax(stringLiteral: """
            get {
               dictionary["\(identifier)"]! as! \(identifierType)
            }
            """),
            AccessorDeclSyntax(stringLiteral: """
            set {
            dictionary["\(identifier)"] = newValue
            }
            """),
        ]
    }
}

// MARK: - Member Attribute

public enum ObjCMembersMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        return ["@objc"]
    }
}

// MARK: - MemberMacro

public enum CustomCodable: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Extract members of the declaration
        let memberList = declaration.memberBlock.members
        guard !memberList.isEmpty else {
            context.diagnose(CodingKeysMacroDiagnostic.noArgument.diagnose(at: node))
            return []
        }
        
        guard declaration.is(StructDeclSyntax.self) || declaration.is(ClassDeclSyntax.self) else {
            context.diagnose(CodingKeysMacroDiagnostic.requiresStructOrClass.diagnose(at: node))
            return []
        }
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
        guard !cases.isEmpty else {
            context.diagnose(CodingKeysMacroDiagnostic.noArgument.diagnose(at: node))
            return []
        }
        // Construct CodingKeys enum
        let codingKeys: DeclSyntax = """
        enum CodingKeys: String, CodingKey {
        \(raw: cases.joined(separator: "\n"))
        }
        """
        return [codingKeys]
    }
}

// extension CustomCodable: ExtensionMacro {
//    public static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
//        let decodableExtension = try ExtensionDeclSyntax("extension \(type.trimmed): Decodable {}")
//        return [decodableExtension]
//    }
// }

public struct CustomCodingKeyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

// MARK: - Extension

public enum EquatableExtensionMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let equatableExtension = try ExtensionDeclSyntax("extension \(type.trimmed): Equatable {}")
        return [equatableExtension]
    }
}

@main
struct CustomCodablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        URLMacro.self,
        CustomCodable.self,
        CustomCodingKeyMacro.self,
        StaticLetMacro.self,
        ConstantMacro.self,
        AddCompletionHandlerMacro.self,
        DictionaryStoragePropertyMacro.self,
        EquatableExtensionMacro.self,
        ObjCMembersMacro.self,
        DictionaryStorageMacro.self,
    ]
}
