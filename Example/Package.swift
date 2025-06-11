// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "OSMDExample",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .executable(
            name: "OSMDExample",
            targets: ["OSMDExample"]),
    ],
    dependencies: [
        .package(path: "../")
    ],
    targets: [
        .executableTarget(
            name: "OSMDExample",
            dependencies: [
                .product(name: "SwiftUIOSMD", package: "SwiftUIOSMD")
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
