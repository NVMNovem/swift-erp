//
//  ERPEnum+Error.swift
//  SwiftERP
//
//  Created by Damian Van de Kauter on 01/09/2024.
//

import Foundation

extension ERPEnum {
    
    /// A type alias that refers to the `ProcessTaskError` enum for the conforming type.
    ///
    /// This type alias provides a convenient way to access the `ProcessTaskError` enum,
    /// which is associated with the specific type that conforms to the `ProcessTask` protocol.
    ///
    typealias Error = ERPENUMError<Self>
}

enum ERPENUMError<P: ERPEnum>: Swift.Error {
    case empty
    case invalidValue
}

extension ERPENUMError: LocalizedError {
    
    var errorCode: Int {
        switch self {
        case .empty:
            return 1
        case .invalidValue:
            return 2
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .empty:
            return String(localized: "The value for this enum is empty.", table: "ERPEnum+Error")
        case .invalidValue:
            return String(localized: "The value for this enum is invalid.", table: "ERPEnum+Error")
        }
    }
}
