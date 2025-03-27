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
            targets: ["MarvelRivalsAPI"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
    ],
    targets: [
        .target(
            name: "MarvelRivalsAPI",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ]),
        .testTarget(
            name: "MarvelRivalsAPITests",
            dependencies: ["MarvelRivalsAPI"]),
    ]
)

