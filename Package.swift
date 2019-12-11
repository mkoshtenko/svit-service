// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "app",
    platforms: [
       .macOS(.v10_14)
    ],
    products: [
        .executable(name: "Run", targets: ["Run"]),
        .library(name: "App", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-beta.2"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-beta.2"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-beta.2"),

        // Used in test environment
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-beta.2"),
    ],
    targets: [
        .target(name: "App",
                dependencies: ["Vapor", "Fluent", "FluentPostgresDriver"]),
        .target(name: "Run",
                dependencies: ["App"]),

        .testTarget(name: "AppTests",
                    dependencies: ["App", "XCTVapor", "FluentSQLiteDriver"])
    ]
)

