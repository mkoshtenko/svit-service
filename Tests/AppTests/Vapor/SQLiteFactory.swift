import FluentSQLiteDriver
import Fluent
import Vapor
import App

public struct SQLiteFactory: DatabaseFactory {
    static let filePath = "tests.sqlite"

    public let databaseId: DatabaseID = .sqlite

    public func configure(_ app: Application) {
        app.databases.use(.sqlite(configuration: .init(storage: .memory)), as: .sqlite, isDefault: true)
    }
}
