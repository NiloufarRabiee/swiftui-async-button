// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AsyncButton",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "AsyncButton",
            targets: ["AsyncButton"]
        )
    ],
    targets: [
        .target(
            name: "AsyncButton"
        ),
        .testTarget(
            name: "AsyncButtonTests",
            dependencies: ["AsyncButton"]
        )
    ]
)
