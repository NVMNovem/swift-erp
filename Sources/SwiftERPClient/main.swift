import SwiftERP

@ERPenum
enum Itemgroup {
    
    @ERPcase(id: "M5Q1Q7CA7P", codable: "Test 1") case TEST_1
    @ERPcase(id: "OA1G29Y2D5", codable: "Test 2") case TEST_2
}

@ERPenum
enum Status {
    
    @ERPcase(id: "TB4AKAOM84", codable: 1) case created
    @ERPcase(id: "DJX3SZZVCN", codable: 2) case started
}
