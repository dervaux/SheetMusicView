// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "PageMarginsDemo",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    dependencies: [
        .package(path: "..")  // Reference to the parent SheetMusicView package
    ],
    targets: [
        .executableTarget(
            name: "PageMarginsDemo",
            dependencies: [
                .product(name: "SheetMusicView", package: "SheetMusicView")
            ]
        )
    ]
)
