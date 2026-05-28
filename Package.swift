// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "swift-erp",
    platforms: [.macOS(.v12), .iOS(.v15), .watchOS(.v6), .tvOS(.v15)],
    products: [
        .library(name: "SwiftERP", targets: ["SwiftERP"]),
        .executable(name: "SwiftERPClient", targets: ["SwiftERPClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: Version(602, 0, 0)),
    ],
    targets: [
        .macro(
            name: "SwiftERPMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "SwiftERP",
            dependencies: ["SwiftERPMacros"]
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(
            name: "SwiftERPClient",
            dependencies: ["SwiftERP"]
        ),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "SwiftERPTests",
            dependencies: [
                "SwiftERPMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
