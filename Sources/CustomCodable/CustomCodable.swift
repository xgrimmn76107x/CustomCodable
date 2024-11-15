// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

// MARK: - ExpressionMacro

@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "CustomCodableMacros", type: "StringifyMacro")

/// Check if provided string literal is a valid URL and produce a non-optional
/// URL value. Emit error otherwise.
@freestanding(expression) // 1
public macro URL(_ stringLiteral: String) -> URL = #externalMacro(module: "CustomCodableMacros", type: "URLMacro")

// MARK: - DeclarationMacro

@freestanding(declaration, names: named(Const))
public macro declareStaticValue<T>(_ value: T) = #externalMacro(module: "CustomCodableMacros", type: "StaticLetMacro")

@freestanding(declaration, names: arbitrary)
public macro Constant(_ value: String) = #externalMacro(module: "CustomCodableMacros", type: "ConstantMacro")

// MARK: - PeerMacro

@attached(peer, names: overloaded)
public macro AddCompletionHandler() = #externalMacro(module: "CustomCodableMacros", type: "AddCompletionHandlerMacro")

@attached(peer)
public macro CodableKey(name: String) = #externalMacro(module: "CustomCodableMacros", type: "CustomCodingKeyMacro")

// MARK: - Accessor

@attached(accessor)
public macro DictionaryStorageProperty(key: String? = nil) = #externalMacro(module: "CustomCodableMacros", type: "DictionaryStoragePropertyMacro")

// MARK: - Member Attribute

@attached(memberAttribute)
public macro memberDeprecated() = #externalMacro(module: "CustomCodableMacros", type: "MemberDeprecatedMacro")

// MARK: - MemberMacro

//@attached(extension, conformances: Decodable)
@attached(member, names: named(CodingKeys))
public macro CustomCodable() = #externalMacro(module: "CustomCodableMacros", type: "CustomCodable")

// MARK: - Extension

@attached(extension, conformances: Equatable)
public macro equatable() = #externalMacro(module: "CustomCodableMacros", type: "EquatableExtensionMacro")
