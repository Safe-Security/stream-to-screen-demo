// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StreamToScreen",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "App",
            targets: ["App"]
        )
    ],
    dependencies: [
        .package(name: "swift-markdown-ui", path: "../swift-markdown-ui-main"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "Algorithms", package: "swift-algorithms")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
