//
//  Diagnostic.swift
//  CustomCodable
//
//  Created by JayHsia on 2024/11/15.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax

public enum CustomError: LocalizedError {
    case message(String)
}

public enum CodingKeysMacroDiagnostic {
    case noArgument
    case requiresStructOrClass
}

extension CodingKeysMacroDiagnostic: DiagnosticMessage {
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }

    public var message: String {
        switch self {
        case .noArgument:
            return "Cannot find argument"
        case .requiresStructOrClass:
            return "'CodingKeys' macro can only be applied to struct."
        }
    }

    public var severity: DiagnosticSeverity { .error }

    public var diagnosticID: MessageID {
        MessageID(domain: "SwiftCodingKeysMacroDiagnostic", id: "CodingKeysMacro.\(self)")
    }
}

public enum AddCompletionMacroDiagnostic: DiagnosticMessage {
    case requiresFunction
    case noReturn
    
    func diagnose(at node: some SyntaxProtocol) -> Diagnostic {
        Diagnostic(node: Syntax(node), message: self)
    }
    
    public var message: String {
        switch self {
        case .requiresFunction:
            return "'AddCompletion' macro can only be applied to function."
        case .noReturn:
            return "'AddCompletion' macro requires a return value."
        }
    }
    
    public var severity: DiagnosticSeverity { .error }
    
    public var diagnosticID: MessageID {
        MessageID(domain: "SwiftAddCompletionMacroDiagnostic", id: "AddCompletionMacro.\(self)")
    }
}
