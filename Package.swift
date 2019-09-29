// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "app",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha.3.1.1"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-alpha.2"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-alpha.3"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Fluent", "FluentPostgresDriver", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

