//
//  CodingKeysGenerator.swift
//  CustomCodable
//
//  Created by JayHsia on 2024/11/19.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct CodingKeysGenerator {
    enum CodingKeysStrategy {
        case equal(String, ExprSyntax)
        case skip(String)
        
        func enumCaseElementSyntax() -> EnumCaseElementSyntax {
            switch self {
            case .equal(let caseName, let value):
                EnumCaseElementSyntax(
                    name: .identifier(caseName),
                    rawValue: InitializerClauseSyntax(
                        equal: .equalToken(),
                        value: value
                    )
                )
            case .skip(let caseName):
                EnumCaseElementSyntax(name: .identifier(caseName))
            }
        }
    }
    
    let strategies: [CodingKeysStrategy]
    
    init(memberList: MemberBlockItemListSyntax) {
        strategies = memberList.compactMap({ member -> CodingKeysStrategy? in
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
                return .equal(propertyName, customKeyValue)
            } else {
                return .skip(propertyName)
            }
        })
    }
    
    func generate() -> [DeclSyntax] {
        let enumDecl = EnumDeclSyntax(name: .identifier("CodingKeys"), inheritanceClause: InheritanceClauseSyntax {
            InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "String"))
            InheritedTypeSyntax(type: TypeSyntax(stringLiteral: "CodingKey"))
        }) {
            strategies.map { MemberBlockItemSyntax(
                decl: EnumCaseDeclSyntax(
                    elements: EnumCaseElementListSyntax(
                        arrayLiteral: $0.enumCaseElementSyntax()))) }
        }
        return [DeclSyntax(enumDecl)]
    }
}
