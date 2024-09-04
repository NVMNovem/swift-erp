//
//  ERPCodableHelpers.swift
//  SwiftERP
//
//  Created by Damian Van de Kauter on 02/09/2024.
//

import SwiftSyntax
import SwiftSyntaxBuilder

internal extension VariableDeclSyntax {
    
    var erpEnum: Bool {
        guard self.getAttributeSyntax(for: "ERPEnum") != nil else { return false }
        return true
    }
    
    var erpEnumCodable: Bool {
        return erpEnumCodableType != nil
    }
    
    var erpEnumCodableType: DeclReferenceExprSyntax? {
        guard let attributeArguments = self.getAttributeSyntax(for: "ERPEnum") else { return nil }
        guard let labeledExpr = attributeArguments.arguments?.as(LabeledExprListSyntax.self)?
            .first(where: { $0.label == nil })
        else { return nil }
        
        return labeledExpr.expression.as(MemberAccessExprSyntax.self)?.base?.as(DeclReferenceExprSyntax.self)
    }
}
