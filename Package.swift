// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "BaziChart",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .executable(name: "BaziChart", targets: ["BaziChart"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/6tail/lunar-swift.git",
            revision: "a7ec0e9b29f84a5d98b09b9ffd31145f17470d56"
        ),
        .package(
            url: "https://github.com/swiftlang/swift-testing.git",
            revision: "48a471ab313e858258ab0b9b0bf2cea55a50cefb"
        )
    ],
    targets: [
        .executableTarget(
            name: "BaziChart",
            dependencies: [
                .product(name: "LunarSwift", package: "lunar-swift")
            ],
            path: "Sources/BaziChart",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "BaziChartTests",
            dependencies: [
                "BaziChart",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/BaziChartTests"
        )
    ]
)
