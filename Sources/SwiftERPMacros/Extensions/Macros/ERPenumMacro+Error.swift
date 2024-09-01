//
//  ERPenumMacro+Error.swift
//  SwiftERP
//
//  Created by Damian Van de Kauter on 01/09/2024.
//

import Foundation
import SwiftSyntax
import SwiftDiagnostics

extension ERPenumMacro {
    
    enum Error: Swift.Error {
        case notAnEnum
        case noERPcases
    }
}

extension ERPenumMacro.Error: DiagnosticMessage {
    
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
            return .error
        }
    }
    
    func fixits(from declaration: some DeclGroupSyntax) -> [FixIt] {
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

extension ERPenumMacro.Error: LocalizedError {
    
    var errorCode: Int {
        switch self {
        case .notAnEnum:
            return 1
        case .noERPcases:
            return 2
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .notAnEnum:
            return String(
                localized: "The macro should be applied to an enum.",
                table: "ERPenumMacro+Error"
            )
        case .noERPcases:
            return String(
                localized: "The enum doesn't contain any ERPcase's.",
                table: "ERPenumMacro+Error"
            )
        }
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
