// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhotoListFeature",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "PhotoListFeature",
            targets: ["PhotoListFeature"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.6.0"),
        .package(url: "https://github.com/kean/Nuke", from: "12.0.0"),
        .package(path: "/Core"),
    ],
    targets: [
        .target(
            name: "PhotoListFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "Nuke"),
                .product(name: "Core", package: "Core")
            ]
        )
    ]
)
