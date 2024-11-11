// The Swift Programming Language
// https://docs.swift.org/swift-book

// MARK: - ExpressionMacro

@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "CustomCodableMacros", type: "StringifyMacro")

// MARK: - DeclarationMacro

@freestanding(declaration, names: named(Const))
public macro declareStaticValue<T>(_ value: T) = #externalMacro(module: "CustomCodableMacros", type: "StaticLetMacro")

@freestanding(declaration, names: arbitrary)
public macro Constant(_ value: String) = #externalMacro(module: "CustomCodableMacros", type: "ConstantMacro")

// MARK: - MemberMacro

@attached(member, names: named(CodingKeys))
public macro CustomCodable() = #externalMacro(module: "CustomCodableMacros", type: "CustomCodable")

// MARK: - PeerMacro

@attached(peer)
public macro CodableKey(name: String) = #externalMacro(module: "CustomCodableMacros", type: "CustomCodingKeyMacro")
