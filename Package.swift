// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "STTwitter",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "STTwitter", targets: ["STTwitter"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "STTwitter",
            path: "STTwitter"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
