// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KitoButtons",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "KitoButtons", targets: ["KitoButtons"])
    ],
    targets: [
        .target(
            name: "KitoButtons",
            path: "Sources/KitoButtons"
        ),
        .testTarget(
            name: "KitoButtonsTests",
            dependencies: ["KitoButtons"],
            path: "Tests/KitoButtonsTests"
        )
    ]
)
