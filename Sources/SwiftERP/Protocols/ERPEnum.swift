//
//  ERPEnum.swift
//  SwiftERP
//
//  Created by Damian Van de Kauter on 01/09/2024.
//

import Foundation

/// A protocol that provides a standardized way to define and manage uniquely identifiable,
/// codable, and hashable types using a `String` identifier.
///
/// The `ERPEnum` protocol is designed to work seamlessly with enumerations or other types
/// where each instance can be uniquely identified by a `String` value. It conforms to
/// `RawRepresentable`, `Codable`, `Identifiable`, and `Hashable`, making it useful in various
/// scenarios where uniqueness, serialization, and hashing are important.
///
/// - Conformance:
///   - `RawRepresentable`: Enables raw value representation, where the raw value is the `id`.
///   - `Codable`: Supports encoding and decoding of the type.
///   - `Identifiable`: Associates the `id` with the `Identifiable` protocol's `id` property.
///   - `Hashable`: Allows instances to be used in collections that require hashing, like sets or dictionaries.
///
public protocol ERPEnum: RawRepresentable<String>, Codable, Identifiable<String>, Hashable {
    
    associatedtype CodableType: Codable, Equatable, CustomStringConvertible
    
    init(id: String) throws
    init(codable: CodableType) throws
    
    var id: String { get }
    var codable: CodableType { get }
}

public extension ERPEnum {
    
    var rawValue: String {
        return self.id
    }
    
    init?(rawValue: String) {
        guard let idInit = try? Self.init(id: rawValue) else { return nil }
        self = idInit
    }
}

public extension ERPEnum {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        switch decoder.idCodableType {
        case .codable:
            let codableType = try container.decode(CodableType.self)
            
            if let stringType = codableType as? String, stringType.isEmpty {
                throw Error.empty
            } else {
                self = try Self(codable: codableType)
            }
        default:
            let codableType = try container.decode(String.self)
            
            if codableType.isEmpty {
                throw Error.empty
            } else {
                self = try Self(id: codableType)
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch encoder.idCodableType {
        case .codable:
            try container.encode(codable)
        default:
            try container.encode(id)
        }
    }
}

public enum IDCodableType: Codable {
    case id
    case codable
}

public extension CodingUserInfoKey {
    static let idCodableType = CodingUserInfoKey(rawValue: "IDCodableType")!
}

public extension Decoder {
    
    var idCodableType: IDCodableType? {
        return self.userInfo[.idCodableType] as? IDCodableType
    }
}

public extension Encoder {
    
    var idCodableType: IDCodableType? {
        return self.userInfo[.idCodableType] as? IDCodableType
    }
}
