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
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            context.diagnose(Diagnose.notAnEnum.diagnostic(node: node, from: declaration))
            return []
        }
        
        let enumCaseDeclSyntaxes = enumDecl.memberBlock.members.compactMap({ $0.decl.as(EnumCaseDeclSyntax.self) })
        let caseTypes = enumCaseDeclSyntaxes.compactMap({ $0.codableAttributeExpression })
        //TODO: Add Diagnose when multiple codable types (not the same type) are set (error)
        //TODO: Add Diagnose when non supported codable types are set (error)
        guard let caseType = caseTypes.first?.getType() else {
            context.diagnose(Diagnose.noERPcases.diagnostic(node: node, from: declaration))
            return []
        }
        
        let idCodableExtension = try ExtensionDeclSyntax("extension \(type.trimmed): ERPEnum") {
            try TypeAliasDeclSyntax("typealias CodableType = \(raw: caseType)")
            try DeclSyntax.idInitializer(enumCaseDeclSyntaxes: enumCaseDeclSyntaxes)
            try DeclSyntax.idVariable(enumCaseDeclSyntaxes: enumCaseDeclSyntaxes)
            try DeclSyntax.codableInitializer(enumCaseDeclSyntaxes: enumCaseDeclSyntaxes, caseType: caseType)
            try DeclSyntax.codableVariable(enumCaseDeclSyntaxes: enumCaseDeclSyntaxes, caseType: caseType)
        }
        
        return [
            idCodableExtension
        ]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
}

public struct ERPcaseMacro: PeerMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        []
    }
}

public struct ERPCodableMacro: ExtensionMacro, MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        let variableDeclSyntaxes: [VariableDeclSyntax]
        switch declaration {
        case let classDecl as ClassDeclSyntax:
            variableDeclSyntaxes = classDecl.memberBlock.members
                .compactMap({ $0.decl.as(VariableDeclSyntax.self) })
                .filter({ $0.isGetSet })
            
        case let structDecl as StructDeclSyntax:
            variableDeclSyntaxes = structDecl.memberBlock.members
                .compactMap({ $0.decl.as(VariableDeclSyntax.self) })
                .filter({ $0.isGetSet })
        default:
            return []
        }
        
        let idCodableExtension = try ExtensionDeclSyntax("extension \(type.trimmed): Codable") {
            try DeclSyntax.codingKeysEnum(variableDeclSyntaxes: variableDeclSyntaxes)
        }
        
        return [
            idCodableExtension
        ]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        let variableDeclSyntaxes: [VariableDeclSyntax]
        switch declaration {
        case let classDecl as ClassDeclSyntax:
            variableDeclSyntaxes = classDecl.memberBlock.members
                .compactMap({ $0.decl.as(VariableDeclSyntax.self) })
                .filter({ $0.isGetSet })
            
        case let structDecl as StructDeclSyntax:
            variableDeclSyntaxes = structDecl.memberBlock.members
                .compactMap({ $0.decl.as(VariableDeclSyntax.self) })
                .filter({ $0.isGetSet })
        default:
            context.diagnose(Diagnose.notAClassOrStruct.diagnostic(node: node, from: declaration))
            return []
        }
        
        var variables: [String]? = nil
        for variableDeclSyntax in variableDeclSyntaxes {
            if let identifier = variableDeclSyntax.patrnNameIdentifier {
                
                if variableDeclSyntax.erpEnum {
                    var newVariables: [String] = variables ?? []
                    newVariables.append("private(set) var \(identifier)Id: String")
                    variables = newVariables
                    
                    if let codableType = variableDeclSyntax.erpEnumCodableType {
                        var newVariables: [String] = variables ?? []
                        newVariables.append("private(set) var \(identifier)Codable: \(codableType)")
                        variables = newVariables
                    }
                }
            }
        }
        
        let initializer = try DeclSyntax.initializer(variableDeclSyntaxes: variableDeclSyntaxes)
        let decodeInitializer = try DeclSyntax.decodeInitializer(variableDeclSyntaxes: variableDeclSyntaxes)
        let encodeFunction = try DeclSyntax.encodeFunction(variableDeclSyntaxes: variableDeclSyntaxes)
        
        if let variables, !variables.isEmpty {
            return [
                SwiftSyntax.DeclSyntax(stringLiteral: variables.joined(separator: "\n")),
                SwiftSyntax.DeclSyntax(initializer),
                SwiftSyntax.DeclSyntax(decodeInitializer),
                SwiftSyntax.DeclSyntax(encodeFunction)
            ]
        } else {
            return [
                SwiftSyntax.DeclSyntax(initializer),
                SwiftSyntax.DeclSyntax(decodeInitializer),
                SwiftSyntax.DeclSyntax(encodeFunction)
            ]
        }
    }
}

public struct ERPEnumMacro: AccessorMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let variableDeclSyntax = declaration.as(VariableDeclSyntax.self),
              let identifier = variableDeclSyntax.patrnNameIdentifier,
              let type = variableDeclSyntax.patrnTypeUnwrapped else {
            return []
        }
        
        let tryClause = variableDeclSyntax.patrnIsOptionalType ? "try?" : "try!"
        
        if variableDeclSyntax.erpEnumCodable {
            return [
                AccessorDeclSyntax(stringLiteral: """
                 get {
                    \(tryClause) \(type)(id: \(identifier)Id)
                 }
                 """),
                AccessorDeclSyntax(stringLiteral: """
                 set {
                 \(identifier)Id = newValue.id
                 \(identifier)Codable = newValue.codable
                 }
                 """)
            ]
        } else {
            return [
                AccessorDeclSyntax(stringLiteral: """
                 get {
                    \(tryClause) \(type)(id: \(identifier)Id)
                 }
                 """),
                AccessorDeclSyntax(stringLiteral: """
                 set {
                 \(identifier)Id = newValue.id
                 }
                 """)
            ]
        }
    }
}

@main
struct IDCodablePlugin: CompilerPlugin {
    
    let providingMacros: [Macro.Type] = [
        ERPenumMacro.self,
        ERPcaseMacro.self,
        
        ERPCodableMacro.self,
        ERPEnumMacro.self
    ]
}
