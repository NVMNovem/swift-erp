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
