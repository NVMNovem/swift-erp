//
//  SwiftERP.swift
//  Funico Scheduler
//
//  Created by Damian Van de Kauter on 01/09/2024.
//

@attached(extension, conformances: ERPEnum, names: named(CodableType), named(init), named(id), named(codable))
@attached(member, names: arbitrary)
public macro ERPenum() = #externalMacro(
    module: "SwiftERPMacros",
    type: "ERPenumMacro"
)

@attached(peer)
public macro ERPcase<C: Swift.Codable>(id: String, codable: C) = #externalMacro(
    module: "SwiftERPMacros",
    type: "ERPcaseMacro"
)

@attached(extension, conformances: Codable, names: named(init), named(ERPCodingKeys))
@attached(member, names: arbitrary)
public macro ERPCodable() = #externalMacro(
    module: "SwiftERPMacros",
    type: "ERPCodableMacro"
)

@attached(accessor)
public macro ERPEnum<T>(_ codableType: T.Type? = nil) = #externalMacro(
    module: "SwiftERPMacros",
    type: "ERPEnumMacro"
)
