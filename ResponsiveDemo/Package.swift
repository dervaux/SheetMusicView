// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ResponsiveDemo",
    platforms: [
        .iOS(.v14),
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "ResponsiveDemo",
            targets: ["ResponsiveDemo"]
        ),
    ],
    dependencies: [
        .package(name: "OSMD_Swift", path: "..")
    ],
    targets: [
        .executableTarget(
            name: "ResponsiveDemo",
            dependencies: [
                .product(name: "SwiftUIOSMD", package: "OSMD_Swift")
            ]
        ),
    ]
)
