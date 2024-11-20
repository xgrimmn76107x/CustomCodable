import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(CustomCodableMacros)
import CustomCodableMacros

let testMacros: [String: Macro.Type] = [
    "stringify": StringifyMacro.self,
    "CustomCodable": CustomCodable.self,
    "CodableKey": CustomCodingKeyMacro.self,
    "Constant": ConstantMacro.self,
    "URL": URLMacro.self,
]
#endif

final class CustomCodableTests: XCTestCase {
    func testMacro() throws {
        #if canImport(CustomCodableMacros)
        assertMacroExpansion(
            """
            #stringify(a + b)
            """,
            expandedSource: """
            (a + b, "a + b")
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStringLiteral() throws {
        #if canImport(CustomCodableMacros)
        assertMacroExpansion(
            #"""
            #stringify("Hello, \(name)")
            """#,
            expandedSource: #"""
            ("Hello, \(name)", #""Hello, \(name)""#)
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testURLWithMacro() throws {
        #if canImport(CustomCodableMacros)
        assertMacroExpansion(
            #"""
            #URL("https://swift.org/")
            """#,
            expandedSource: #"""
            URL(string: "https://swift.org/")!
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testMacroWithConstants() throws {
        #if canImport(CustomCodableMacros)
        assertMacroExpansion(
            """
            #Constant("app_icon")
            """,
            expandedSource: """
            public static var appIcon = "app_icon"
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithCodable() throws {
        #if canImport(CustomCodableMacros)
        assertMacroExpansion(
            """
            @CustomCodable
            struct CustomCodableString: Decodable {
                @CodableKey(name: "OtherName")
                var propertyWithOtherName: String
                var propertyWithSameName: Bool
            }
            """,
            expandedSource: """
            struct CustomCodableString: Decodable {
                var propertyWithOtherName: String
                var propertyWithSameName: Bool
            
                enum CodingKeys: String, CodingKey {
                    case propertyWithOtherName = "OtherName"
                    case propertyWithSameName
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
