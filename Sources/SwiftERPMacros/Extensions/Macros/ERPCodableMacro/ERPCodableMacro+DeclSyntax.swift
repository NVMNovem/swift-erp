//
//  File.swift
//  SwiftERP
//
//  Created by Damian Van de Kauter on 02/09/2024.
//

import SwiftSyntax

extension ERPCodableMacro {
    
    enum DeclSyntax {
        static func codingKeysEnum(variableDeclSyntaxes: [VariableDeclSyntax]) throws -> EnumDeclSyntax {
            try EnumDeclSyntax("fileprivate enum ERPCodingKeys: String, CodingKey") {
                for varDecl in variableDeclSyntaxes {
                    if let identifier = varDecl.patrnNameIdentifier?.identifier {
                        if varDecl.erpEnum {
                            if varDecl.erpEnumCodable {
                                """
                                case \(identifier) = "\(identifier)"
                                case \(identifier)Id = "erp_\(identifier)Id"
                                case \(identifier)Codable = "erp_\(identifier)Codable"
                                """
                            } else {
                                """
                                case \(identifier) = "\(identifier)"
                                case \(identifier)Id = "erp_\(identifier)Id"
                                """
                            }
                        } else {
                            """
                            case \(identifier) = "\(identifier)"
                            """
                        }
                    }
                }
            }
        }
        
        static func initializer(variableDeclSyntaxes: [VariableDeclSyntax]) throws -> InitializerDeclSyntax {
            let parameters = variableDeclSyntaxes.compactMap({ decl -> String? in
                guard let name = decl.patrnNameIdentifier, let type = decl.patrnType else { return nil }
                return "\(name): \(type)"
            })
            
            return try InitializerDeclSyntax("init(\(raw: parameters.joined(separator: ", ")))") {
                for varDecl in variableDeclSyntaxes {
                    if let identifier = varDecl.patrnNameIdentifier {
                        let optDecl = varDecl.patrnIsOptionalType ? "?" : ""
                        if varDecl.erpEnum {
                            if varDecl.erpEnumCodable {
                                """
                                \(identifier)Id = \(identifier)\(raw: optDecl).id
                                \(identifier)Codable = \(identifier)\(raw: optDecl).codable
                                """
                            } else {
                                """
                                \(identifier)Id = \(identifier)\(raw: optDecl).id
                                """
                            }
                        }
                    }
                }
                for varDecl in variableDeclSyntaxes {
                    if let identifier = varDecl.patrnNameIdentifier {
                        """
                        self.\(identifier) = \(identifier)
                        """
                    }
                }
            }
        }
        
        static func decodeInitializer(variableDeclSyntaxes: [VariableDeclSyntax]) throws -> InitializerDeclSyntax {
            try InitializerDeclSyntax("init(from decoder: Decoder) throws") {
                """
                let values = try decoder.container(keyedBy: ERPCodingKeys.self)
                \n
                """
                for varDecl in variableDeclSyntaxes {
                    let decodeType = varDecl.patrnIsOptionalType ? "decodeIfPresent" : "decode"
                    
                    if varDecl.erpEnum {
                        if let identifier = varDecl.patrnNameIdentifier {
                            if let codableType = varDecl.erpEnumCodableType {
                                """
                                \(identifier)Id = try values.\(raw: decodeType)(String.self, forKey: .\(identifier)Id)
                                \(identifier)Codable = try values.\(raw: decodeType)(\(codableType).self, forKey: .\(identifier)Codable)
                                """
                            } else {
                                """
                                \(identifier)Id = try values.\(raw: decodeType)(String.self, forKey: .\(identifier)Id)
                                """
                            }
                        }
                    } else {
                        if let identifier = varDecl.patrnNameIdentifier,
                           let type = varDecl.patrnTypeUnwrapped {
                        """
                        \(identifier) = try values.\(raw: decodeType)(\(type).self, forKey: .\(identifier))
                        """
                        }
                    }
                }
            }
        }
        
        static func encodeFunction(variableDeclSyntaxes: [VariableDeclSyntax]) throws -> FunctionDeclSyntax {
            try FunctionDeclSyntax("func encode(to encoder: Encoder) throws") {
                """
                var container = encoder.container(keyedBy: ERPCodingKeys.self)
                \n
                """
                for varDecl in variableDeclSyntaxes {
                    let encodeType = varDecl.patrnIsOptionalType ? "encodeIfPresent" : "encode"
                    
                    if varDecl.erpEnum {
                        if let identifier = varDecl.patrnNameIdentifier {
                            if varDecl.erpEnumCodable {
                                """
                                try container.\(raw: encodeType)(\(identifier)Id, forKey: .\(identifier)Id)
                                try container.\(raw: encodeType)(\(identifier)Codable, forKey: .\(identifier)Codable)
                                """
                            } else {
                                """
                                try container.\(raw: encodeType)(\(identifier)Id, forKey: .\(identifier)Id)
                                """
                            }
                        }
                    } else {
                        if let identifier = varDecl.patrnNameIdentifier {
                            """
                            try container.\(raw: encodeType)(\(identifier), forKey: .\(identifier))
                            """
                        }
                    }
                }
            }
        }
    }
}
