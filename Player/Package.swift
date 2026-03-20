// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Player",
    platforms: [
        .tvOS(.v26)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Player",
            targets: ["Player"]
        ),
    ],
    dependencies: [
        .package(path: "../JellyfinSDK"),
        .package(path: "../Core")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Player",
            dependencies: [
                .product(name: "JellyfinSDK", package: "JellyfinSDK"),
                .product(name: "Core", package: "Core")
            ]
        ),

    ]
)
