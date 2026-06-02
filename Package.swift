// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "7zzGUI",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "7zzGUI",
            resources: [.copy("Resources/language")]
        )
    ]
)
