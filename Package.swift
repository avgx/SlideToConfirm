// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SlideToConfirm",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "SlideToConfirm",
            targets: ["SlideToConfirm"]
        ),
    ],
    targets: [
        .target(
            name: "SlideToConfirm",
            resources: [.process("Resources")],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .testTarget(
            name: "SlideToConfirmTests",
            dependencies: ["SlideToConfirm"],
        ),
    ]
)
