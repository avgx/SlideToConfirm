// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SlideToConfirm",
    products: [
        .library(
            name: "SlideToConfirm",
            targets: ["SlideToConfirm"]
        ),
    ],
    targets: [
        .target(
            name: "SlideToConfirm",
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
