//
//  DictionaryStorageMacro.swift
//  CustomCodable
//
//  Created by JayHsia on 2024/11/15.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct DictionaryStorageMacro {}

extension DictionaryStorageMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let storage: DeclSyntax = "var dictionary: [String: Any] = [:]"
        return [
            storage.with(\.leadingTrivia, [.newlines(1), .spaces(2)]),
        ]
    }
}

extension DictionaryStorageMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard member.as(VariableDeclSyntax.self) != nil
        else {
            return []
        }

        return [
            AttributeSyntax(
                attributeName: IdentifierTypeSyntax(
                    name: .identifier("DictionaryStorageProperty")
                )
            )
            .with(\.leadingTrivia, [.newlines(1), .spaces(2)]),
        ]
    }
}
