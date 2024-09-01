//
//  ERPEnumError.swift
//  SwiftERP
//
//  Created by Damian Van de Kauter on 01/09/2024.
//

import Foundation

public enum ERPEnumError: Error {
    case invalidId
    case invalidCodable
}

extension ERPEnumError: LocalizedError {
    
    var errorCode: Int {
        switch self {
        case .invalidId:
            return 1
        case .invalidCodable:
            return 2
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidId:
            return String(
                localized: "The id is invalid for this enum.",
                table: "FSError"
            )
        case .invalidCodable:
            return String(
                localized: "The codable is invalid for this enum.",
                table: "FSError"
            )
        }
    }
}
