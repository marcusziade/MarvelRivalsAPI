// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MarvelRivalsAPI",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "MarvelRivalsAPI",
            targets: ["MarvelRivalsAPI"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MarvelRivalsAPI",
            dependencies: []),
        .testTarget(
            name: "MarvelRivalsAPITests",
            dependencies: ["MarvelRivalsAPI"]),
    ]
)

