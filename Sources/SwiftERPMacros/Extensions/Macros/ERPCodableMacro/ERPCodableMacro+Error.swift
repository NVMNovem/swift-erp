//
//  ERPCodableMacro+Error.swift
//  SwiftERP
//
//  Created by Damian Van de Kauter on 01/09/2024.
//

import Foundation
import SwiftSyntax
import SwiftDiagnostics

extension ERPCodableMacro {
    
    enum Error: Swift.Error {
        case notAClassOrStruct
    }
}

extension ERPCodableMacro.Error: DiagnosticMessage {
    
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
    
    func fixits(from declaration: some DeclGroupSyntax) -> [FixIt] {
        switch self {
        case .notAClassOrStruct:
            return []
        }
    }
}

extension ERPCodableMacro.Error: LocalizedError {
    
    var errorCode: Int {
        switch self {
        case .notAClassOrStruct:
            return 1
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .notAClassOrStruct:
            return String(
                localized: "The macro should be applied to a class or a struct.",
                table: "ERPCodableMacro+Error"
            )
        }
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
