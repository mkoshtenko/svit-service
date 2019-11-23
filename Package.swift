// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "app",
    products: [
        .executable(name: "Run", targets: ["Run"]),
        .library(name: "App", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-beta"),
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.0.0-beta"),
        .package(url: "https://github.com/vapor/fluent-kit.git", .exact("1.0.0-beta.1")),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-beta"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-beta"),

        // Used in test environment
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-beta"),
    ],
    targets: [
        .target(name: "App",
                dependencies: ["Vapor", "Fluent", "FluentPostgresDriver"]),
        .target(name: "Run",
                dependencies: ["App"]),

        .testTarget(name: "AppTests",
                    dependencies: ["App", "FluentSQLiteDriver"])
    ]
)

