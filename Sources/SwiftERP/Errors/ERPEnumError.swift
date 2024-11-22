//
//  ERPEnumError.swift
//  SwiftERP
//
//  Created by Damian Van de Kauter on 01/09/2024.
//

import Foundation

public enum ERPEnumError<CodableType: Codable & Equatable & CustomStringConvertible & Sendable>: Error {
    case invalidId(_ id: CodableType)
    case invalidCodable(_ codable: CodableType)
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
        case .invalidId(let id):
            return String(
                localized: "The id '\(id.description)' is invalid for this enum.",
                table: "FSError"
            )
        case .invalidCodable(let codable):
            return String(
                localized: "The codable '\(codable.description)' is invalid for this enum.",
                table: "FSError"
            )
        }
    }
}
