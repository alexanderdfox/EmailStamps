// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "EmailStampApp",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "EmailStampExtension",
            type: .dynamic,
            targets: ["EmailStampApp"])
    ],
    targets: [
        .target(
            name: "EmailStampApp",
            dependencies: [],
            path: "Sources/EmailStampApp",
            linkerSettings: [
                .linkedFramework("MailKit", .when(platforms: [.macOS])),
                .linkedFramework("CryptoKit", .when(platforms: [.macOS])),
                .linkedFramework("CoreImage", .when(platforms: [.macOS]))
            ]
        )
    ]
)

