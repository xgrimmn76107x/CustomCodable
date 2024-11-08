// The Swift Programming Language
// https://docs.swift.org/swift-book

// MARK: - ExpressionMacro

@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "CustomCodableMacros", type: "StringifyMacro")

// MARK: - DeclarationMacro

@freestanding(declaration, names: named(MyClass))
public macro FuncUnique() = #externalMacro(module: "CustomCodableMacros", type: "FuncUniqueMacro")

@freestanding(declaration, names: named(Const))
public macro declareStaticValue<T>(_ value: T) = #externalMacro(module: "CustomCodableMacros", type: "StaticLetMacro")

// MARK: - MemberMacro

@attached(member, names: named(CodingKeys))
public macro CustomCodable() = #externalMacro(module: "CustomCodableMacros", type: "CustomCodable")

// MARK: - PeerMacro

@attached(peer)
public macro CodableKey(name: String) = #externalMacro(module: "CustomCodableMacros", type: "CustomCodingKeyMacro")
