//
//  ERPEnumError.swift
//  SwiftERP
//
//  Created by Damian Van de Kauter on 01/09/2024.
//

import Foundation

public enum ERPEnumError<CodableType: Codable & Equatable & CustomStringConvertible & Sendable, T: ERPEnum>: Error {
    case invalidId(_ id: CodableType, erpEnum: T.Type)
    case invalidCodable(_ codable: CodableType, erpEnum: T.Type)
}

extension ERPEnumError: Sendable {}

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
        case .invalidId(let id, let erpEnum):
            return String(
                localized: "The id '\(id.description)' is invalid for the enum '\(String(describing: erpEnum))'.",
                table: "FSError"
            )
        case .invalidCodable(let codable, let erpEnum):
            return String(
                localized: "The codable '\(codable.description)' is invalid for the enum '\(String(describing: erpEnum))'.",
                table: "FSError"
            )
        }
    }
}
