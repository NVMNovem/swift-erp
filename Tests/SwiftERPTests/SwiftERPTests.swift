import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(SwiftERPMacros)
import SwiftERPMacros

let testMacros: [String: Macro.Type] = [
    "ERPenum": ERPenumMacro.self
]
#endif

final class SwiftERPTests: XCTestCase {
    func testMacro1() throws {
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
    
    func testMacro2() throws {
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
}
