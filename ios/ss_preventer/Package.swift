// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ss_preventer",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "ss-preventer", targets: ["ss_preventer"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "ss_preventer",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
    ]
)
