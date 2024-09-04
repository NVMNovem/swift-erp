//
//  ERPenumMacro+Error.swift
//  SwiftERP
//
//  Created by Damian Van de Kauter on 01/09/2024.
//

import Foundation

extension ERPenumMacro {
    
    enum Error: Swift.Error {
        case notAnEnum
        case noERPcases
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
