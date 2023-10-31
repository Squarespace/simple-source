// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-simple-source",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "SimpleSource",
            targets: ["SimpleSource"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Quick", from: "7.3.0"),
        .package(url: "https://github.com/Quick/Nimble", from: "12.3.0"),
    ],
    targets: [
        .target(
            name: "SimpleSource"
        ),
        .testTarget(
            name: "SimpleSourceTests",
            dependencies: [
                "SimpleSource",
                .product(name: "Quick", package: "Quick"),
                .product(name: "Nimble", package: "Nimble"),
            ]
        ),
    ]
)
