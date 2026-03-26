// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NightShift",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "NightShift",
            path: "."
        )
    ]
)
