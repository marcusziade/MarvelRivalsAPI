// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MarvelRivalsAPI",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "MarvelRivalsAPI",
            targets: ["MarvelRivalsAPI"]),
        .executable(
            name: "RivalTracker",
            targets: ["RivalTracker"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-system.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "MarvelRivalsAPI",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ]),
        .executableTarget(
            name: "RivalTracker",
            dependencies: [
                "MarvelRivalsAPI",
                .product(name: "Logging", package: "swift-log"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "SystemPackage", package: "swift-system"),
            ]),
        .testTarget(
            name: "MarvelRivalsAPITests",
            dependencies: ["MarvelRivalsAPI"]),
    ]
)

