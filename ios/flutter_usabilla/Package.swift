// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "flutter_usabilla",
    platforms: [.iOS("12.0")],
    products: [
        .library(name: "flutter-usabilla", targets: ["flutter_usabilla"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/usabilla/usabilla-u4a-ios-swift-sdk.git",
            from: "6.17.1"
        ),
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "flutter_usabilla",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Usabilla", package: "usabilla-u4a-ios-swift-sdk")
            ],
            path: "Sources/flutter_usabilla"
        )
    ]
)