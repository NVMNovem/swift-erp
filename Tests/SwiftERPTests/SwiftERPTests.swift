import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SwiftERPMacros)
import SwiftERPMacros

let testMacros: [String: Macro.Type] = [
    "ERPenum": ERPenumMacro.self,
    
    "ERPCodable": ERPCodableMacro.self,
    "ERPEnum": ERPEnumMacro.self
]
#endif

final class SwiftERPTests: XCTestCase {
    func testERPenum1() throws {
#if canImport(SwiftERPMacros)
        assertMacroExpansion(
            """
            @ERPenum
            enum Itemgroup {
            
                @ERPcase(id: "M5Q1Q7CA7P", codable: "Test 1") case TEST_1
                @ERPcase(id: "OA1G29Y2D5", codable: "Test 2") case TEST_2
            }
            """,
            expandedSource:
            """
            enum Itemgroup {
            
                @ERPcase(id: "M5Q1Q7CA7P", codable: "Test 1") case TEST_1
                @ERPcase(id: "OA1G29Y2D5", codable: "Test 2") case TEST_2
            }
            
            extension Itemgroup: ERPEnum {
                typealias CodableType = String
                init(id: String) throws {
                    switch id {
                    case "M5Q1Q7CA7P":
                        self = .TEST_1
                    case "OA1G29Y2D5":
                        self = .TEST_2
                    default:
                        throw ERPEnumError.invalidId
                    }
                }
                var id: String {
                    switch self {
                    case .TEST_1:
                        return "M5Q1Q7CA7P"
                    case .TEST_2:
                        return "OA1G29Y2D5"
                    }
                }
                init(codable: String) throws {
                    switch codable {
                    case "Test 1":
                        self = .TEST_1
                    case "Test 2":
                        self = .TEST_2
                    default:
                        throw ERPEnumError.invalidCodable
                    }
                }
                var codable: String {
                    switch self {
                    case .TEST_1:
                        return "Test 1"
                    case .TEST_2:
                        return "Test 2"
                    }
                }
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testERPenum2() throws {
#if canImport(SwiftERPMacros)
        assertMacroExpansion(
            """
            @ERPenum
            enum Status {
            
                @ERPcase(id: "TB4AKAOM84", codable: 1) case created
                @ERPcase(id: "DJX3SZZVCN", codable: 2) case started
            }
            """,
            expandedSource:
            """
            enum Status {
            
                @ERPcase(id: "TB4AKAOM84", codable: 1) case created
                @ERPcase(id: "DJX3SZZVCN", codable: 2) case started
            }
            
            extension Status: ERPEnum {
                typealias CodableType = Int
                init(id: String) throws {
                    switch id {
                    case "TB4AKAOM84":
                        self = .created
                    case "DJX3SZZVCN":
                        self = .started
                    default:
                        throw ERPEnumError.invalidId
                    }
                }
                var id: String {
                    switch self {
                    case .created:
                        return "TB4AKAOM84"
                    case .started:
                        return "DJX3SZZVCN"
                    }
                }
                init(codable: Int) throws {
                    switch codable {
                    case 1:
                        self = .created
                    case 2:
                        self = .started
                    default:
                        throw ERPEnumError.invalidCodable
                    }
                }
                var codable: Int {
                    switch self {
                    case .created:
                        return 1
                    case .started:
                        return 2
                    }
                }
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testERPCodable1() throws {
#if canImport(SwiftERPMacros)
        assertMacroExpansion(
            """
            @ERPCodable
            final class ProductionOrder {
            
                typealias SortValue = Article
                var sortValue: SortValue { return self.article }
            
                var po: String
                var article: String
                @ERPEnum(String.self) var itemgroup: Itemgroup
                @ERPEnum(Int.self) var status: Status
                var name: String?
            }
            """,
            expandedSource:
            """
            final class ProductionOrder {
            
                typealias SortValue = Article
                var sortValue: SortValue { return self.article }
            
                var po: String
                var article: String
                var itemgroup: Itemgroup {
                    get {
                       try! Itemgroup(id: itemgroupId)
                    }
                    set {
                        itemgroupId = newValue.id
                        itemgroupCodable = newValue.codable
                    }
                }
                var status: Status {
                    get {
                       try! Status(id: statusId)
                    }
                    set {
                        statusId = newValue.id
                        statusCodable = newValue.codable
                    }
                }
                var name: String?
            
                private(set) var itemgroupId: String
                private(set) var itemgroupCodable: String
                private(set) var statusId: String
                private(set) var statusCodable: Int
            
                init(po: String, article: String, itemgroup: Itemgroup, status: Status, name: String?) {
                    self.po = po
                    self.article = article
                    self.itemgroupId = itemgroup.id
                self.itemgroupCodable = itemgroup.codable
                    self.statusId = status.id
                self.statusCodable = status.codable
                    self.name = name
                }
            
                init(from decoder: Decoder) throws {
                    let values = try decoder.container(keyedBy: ERPCodingKeys.self)
            
                    po = try values.decode(String.self, forKey: .po)
                    article = try values.decode(String.self, forKey: .article)
                    itemgroupId = try values.decode(String.self, forKey: .itemgroupId)
                itemgroupCodable = try values.decode(String.self, forKey: .itemgroupCodable)
                    statusId = try values.decode(String.self, forKey: .statusId)
                statusCodable = try values.decode(Int.self, forKey: .statusCodable)
                    name = try values.decodeIfPresent(String.self, forKey: .name)
                }
            
                func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: ERPCodingKeys.self)
            
                    try container.encode(po, forKey: .po)
                    try container.encode(article, forKey: .article)
                    try container.encode(itemgroupId, forKey: .itemgroupId)
                try container.encode(itemgroupCodable, forKey: .itemgroupCodable)
                    try container.encode(statusId, forKey: .statusId)
                try container.encode(statusCodable, forKey: .statusCodable)
                    try container.encodeIfPresent(name, forKey: .name)
                }
            }
            
            extension ProductionOrder: Codable {
                fileprivate enum ERPCodingKeys: String, CodingKey {
                    case po = "po"
                    case article = "article"
                    case itemgroup = "itemgroup"
                    case itemgroupId = "erp_itemgroupId"
                    case itemgroupCodable = "erp_itemgroupCodable"
                    case status = "status"
                    case statusId = "erp_statusId"
                    case statusCodable = "erp_statusCodable"
                    case name = "name"
                }
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
