import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct ERPenumMacro: ExtensionMacro, MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw Error.notAnEnum
        }
        
        let enumCaseDecles = enumDecl.memberBlock.members.compactMap({ $0.decl.as(EnumCaseDeclSyntax.self) })
        let caseTypes = enumCaseDecles.compactMap({ $0.codableAttributeExpression })
        guard let caseType = caseTypes.first?.getType() else {
            throw Error.noERPcases
        }
        
        let idInitializer = try InitializerDeclSyntax("init(id: String) throws") {
            try SwitchExprSyntax("switch id") {
                for enumCaseDecl in enumCaseDecles {
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
                default: throw ERPEnumError.invalidId
                """
            }
        }
        let idVariable = try VariableDeclSyntax("var id: String") {
            try SwitchExprSyntax("switch self") {
                for enumCaseDecl in enumCaseDecles {
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
        
        let codableInitializer = try InitializerDeclSyntax("init(codable: \(raw: caseType)) throws") {
            try SwitchExprSyntax("switch codable") {
                for enumCaseDecl in enumCaseDecles {
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
                default: throw ERPEnumError.invalidCodable
                """
            }
        }
        let codableVariable = try VariableDeclSyntax("var codable: \(raw: caseType)") {
            try SwitchExprSyntax("switch self") {
                for enumCaseDecl in enumCaseDecles {
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
        
        let idCodableExtension = try ExtensionDeclSyntax("extension \(type.trimmed): ERPEnum") {
            """
            typealias CodableType = \(raw: caseType)
            """
            idInitializer
            idVariable
            codableInitializer
            codableVariable
        }
        
        return [
            idCodableExtension
        ]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            //TODO: Emit an error here
            return []
        }
        return []
    }
}

enum ERPcaseMacro: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

@main
struct IDCodablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ERPenumMacro.self,
        ERPcaseMacro.self
    ]
}
