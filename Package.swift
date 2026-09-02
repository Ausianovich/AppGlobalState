// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppGlobalState",
    platforms: [
        .macOS(.v26), .iOS(.v26)
    ],
    products: [
        .library(
            name: "AppGlobalState",
            targets: ["AppGlobalState"]
        ),
        .library(
            name: "AppGlobalStateUI",
            targets: ["AppGlobalStateUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "AppGlobalState",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "Sharing", package: "swift-sharing"),
            ]
        ),
        .target(
            name: "AppGlobalStateUI",
            dependencies: [
                "AppGlobalState",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "AppGlobalStateTests",
            dependencies: [
                "AppGlobalState",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
