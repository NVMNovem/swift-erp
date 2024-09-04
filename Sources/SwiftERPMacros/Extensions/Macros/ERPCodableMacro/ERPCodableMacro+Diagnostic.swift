//
//  ERPCodableMacro+Diagnostic.swift
//  SwiftERP
//
//  Created by Damian Van de Kauter on 02/09/2024.
//

import Foundation
import SwiftSyntax
import SwiftDiagnostics

extension ERPCodableMacro {
    
    enum Diagnose {
        case notAClassOrStruct
    }
}

extension ERPCodableMacro.Diagnose: DiagnosticMessage {
    
    var message: String {
        switch self {
        case .notAClassOrStruct:
            return "The macro should be applied to a class or a struct"
        }
    }
    
    var diagnosticID: SwiftDiagnostics.MessageID {
        switch self {
        case .notAClassOrStruct:
            return MessageID(domain: "ERPCodable", id: "notAClassOrStruct")
        }
    }
    
    var severity: SwiftDiagnostics.DiagnosticSeverity {
        switch self {
        case .notAClassOrStruct:
            return .error
        }
    }
    
    func fixIts(from declaration: some DeclGroupSyntax) -> [FixIt] {
        switch self {
        case .notAClassOrStruct:
            return []
        }
    }
}

extension ERPCodableMacro.Diagnose {
    
    func diagnostic(node: some SyntaxProtocol, from declaration: some DeclGroupSyntax) -> SwiftDiagnostics.Diagnostic {
        Diagnostic(node: node, message: self, fixIts: fixIts(from: declaration))
    }
}

struct ERPCodableFixit: FixItMessage {
    var message: String
    var fixItID: MessageID
    
    init(_ message: String, diagnostic: DiagnosticMessage) {
        self.message = message
        self.fixItID = diagnostic.diagnosticID
    }
}
