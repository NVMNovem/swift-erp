//
//  ERPenumMacro+Diagnostic.swift
//  SwiftERP
//
//  Created by Damian Van de Kauter on 02/09/2024.
//

import Foundation
import SwiftSyntax
import SwiftDiagnostics

extension ERPenumMacro {
    
    enum Diagnose {
        case notAnEnum
        case noERPcases
    }
}

extension ERPenumMacro.Diagnose: DiagnosticMessage {
    
    var message: String {
        switch self {
        case .notAnEnum:
            return "The macro should be applied to an enum"
        case .noERPcases:
            return "The enum doesn't contain any ERPcase's"
        }
    }
    
    var diagnosticID: SwiftDiagnostics.MessageID {
        switch self {
        case .notAnEnum:
            return MessageID(domain: "ERPenum", id: "notAnEnum")
        case .noERPcases:
            return MessageID(domain: "ERPenum", id: "noERPcases")
        }
    }
    
    var severity: SwiftDiagnostics.DiagnosticSeverity {
        switch self {
        case .notAnEnum:
            return .error
        case .noERPcases:
            return .warning
        }
    }
    
    func fixIts(from declaration: some DeclGroupSyntax) -> [FixIt] {
        switch self {
        case .notAnEnum:
            return []
        case .noERPcases:
            if var newDeclaration = declaration.as(EnumDeclSyntax.self) {
                let oldName = newDeclaration.name
                let newNameText = "prefix" + oldName.text
                
                newDeclaration.name = .identifier(
                    newNameText, leadingTrivia: oldName.leadingTrivia, trailingTrivia: oldName.trailingTrivia, presence: oldName.presence
                )
                
                return [
                    FixIt(message: ERPModelFixit("Add ERPcase's to the enum", diagnostic: self),
                          changes: [.replace(oldNode: declaration._syntaxNode, newNode: newDeclaration._syntaxNode)])
                ]
            }
            return []
        }
    }
}

extension ERPenumMacro.Diagnose {
    
    func diagnostic(node: some SyntaxProtocol, from declaration: some DeclGroupSyntax) -> SwiftDiagnostics.Diagnostic {
        Diagnostic(node: node, message: self, fixIts: fixIts(from: declaration))
    }
}

struct ERPModelFixit: FixItMessage {
    var message: String
    var fixItID: MessageID
    
    init(_ message: String, diagnostic: DiagnosticMessage) {
        self.message = message
        self.fixItID = diagnostic.diagnosticID
    }
}
