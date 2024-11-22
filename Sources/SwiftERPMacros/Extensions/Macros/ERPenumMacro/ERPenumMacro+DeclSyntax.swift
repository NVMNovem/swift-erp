//
//  ERPenumMacro+DeclSyntax.swift
//  SwiftERP
//
//  Created by Damian Van de Kauter on 02/09/2024.
//

import SwiftSyntax

extension ERPenumMacro {
    
    enum DeclSyntax {
        static func idInitializer(enumCaseDeclSyntaxes: [EnumCaseDeclSyntax]) throws -> InitializerDeclSyntax {
            try InitializerDeclSyntax("init(id: String) throws") {
                try SwitchExprSyntax("switch id") {
                    for enumCaseDecl in enumCaseDeclSyntaxes {
                        for enumCaseElement in enumCaseDecl.elements {
                            let identifier = enumCaseElement.name
                            if let id = enumCaseDecl.idAttributeExpression {
                            """
                            case \(id.trimmed): self = .\(identifier)
                            """
                            }
                        }
                    }
                """
                default: throw ERPEnumError.invalidId(id)
                """
                }
            }
        }
        
        static func idVariable(enumCaseDeclSyntaxes: [EnumCaseDeclSyntax]) throws -> VariableDeclSyntax {
            try VariableDeclSyntax("var id: String") {
                try SwitchExprSyntax("switch self") {
                    for enumCaseDecl in enumCaseDeclSyntaxes {
                        for enumCaseElement in enumCaseDecl.elements {
                            let identifier = enumCaseElement.name
                            if let id = enumCaseDecl.idAttributeExpression {
                            """
                            case .\(identifier): return \(id.trimmed)
                            """
                            }
                        }
                    }
                }
            }
        }
        
        static func codableInitializer(enumCaseDeclSyntaxes: [EnumCaseDeclSyntax], caseType: String) throws -> InitializerDeclSyntax {
            try InitializerDeclSyntax("init(codable: \(raw: caseType)) throws") {
                try SwitchExprSyntax("switch codable") {
                    for enumCaseDecl in enumCaseDeclSyntaxes {
                        for enumCaseElement in enumCaseDecl.elements {
                            let identifier = enumCaseElement.name
                            if let codable = enumCaseDecl.codableAttributeExpression {
                            """
                            case \(codable.trimmed): self = .\(identifier)
                            """
                            }
                        }
                    }
                """
                default: throw ERPEnumError.invalidCodable(codable)
                """
                }
            }
        }
        
        static func codableVariable(enumCaseDeclSyntaxes: [EnumCaseDeclSyntax], caseType: String) throws -> VariableDeclSyntax {
            try VariableDeclSyntax("var codable: \(raw: caseType)") {
                try SwitchExprSyntax("switch self") {
                    for enumCaseDecl in enumCaseDeclSyntaxes {
                        for enumCaseElement in enumCaseDecl.elements {
                            let identifier = enumCaseElement.name
                            if let codable = enumCaseDecl.codableAttributeExpression {
                            """
                            case .\(identifier): return \(codable.trimmed)
                            """
                            }
                        }
                    }
                }
            }
        }
    }
}
