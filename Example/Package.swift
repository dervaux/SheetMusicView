// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "OSMDExample",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "OSMDExample",
            targets: ["OSMDExample"]),
    ],
    dependencies: [
        .package(name: "SheetMusicView", path: "../")
    ],
    targets: [
        .executableTarget(
            name: "OSMDExample",
            dependencies: [
                .product(name: "SheetMusicView", package: "SheetMusicView")
            ]
        ),
    ]
)
