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

// Declarations with a specific fixed name: named(<declaration-name>)
@freestanding(declaration, names: named(Const))
public macro declareStaticValue<T>(_ value: T) = #externalMacro(module: "CustomCodableMacros", type: "StaticLetMacro")


// Declarations whose names cannot be described statically, for example because they are derived from other inputs: arbitrary
@freestanding(declaration, names: arbitrary)
public macro Constant(_ value: String) = #externalMacro(module: "CustomCodableMacros", type: "ConstantMacro")

// MARK: - PeerMacro

// Declarations that have the same base name as the declaration to which the macro is attached, and are therefore overloaded with it: overloaded.
@attached(peer, names: overloaded)
public macro AddCompletionHandler() = #externalMacro(module: "CustomCodableMacros", type: "AddCompletionHandlerMacro")

@attached(peer)
public macro CodableKey(name: String) = #externalMacro(module: "CustomCodableMacros", type: "CustomCodingKeyMacro")

// MARK: - Accessor

@attached(accessor)
public macro DictionaryStorageProperty(key: String? = nil) = #externalMacro(module: "CustomCodableMacros", type: "DictionaryStoragePropertyMacro")

// MARK: - Member Attribute

@attached(memberAttribute)
public macro ObjCMembers() = #externalMacro(module: "CustomCodableMacros", type: "ObjCMembersMacro")

// MARK: - MemberMacro

// @attached(extension, conformances: Decodable)
@attached(member, names: named(CodingKeys))
public macro CustomCodable() = #externalMacro(module: "CustomCodableMacros", type: "CustomCodable")

// MARK: - Extension

@attached(extension, conformances: Equatable)
public macro equatable() = #externalMacro(module: "CustomCodableMacros", type: "EquatableExtensionMacro")

/// Wrap up the stored properties of the given type in a dictionary,
/// turning them into computed properties.
///
/// This macro composes three different kinds of macro expansion:
///   * Member-attribute macro expansion, to put itself on all stored properties
///     of the type it is attached to.
///   * Member macro expansion, to add a `dictionary` property with the actual
///     dictionary.
///   * Accessor macro expansion, to turn the stored properties into computed
///     properties that look for values in the `dictionary` property.
@attached(member, names: named(dictionary))
@attached(memberAttribute)
public macro DictionaryStorage() = #externalMacro(module: "CustomCodableMacros", type: "DictionaryStorageMacro")
