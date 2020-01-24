import FluentSQLiteDriver
import Fluent
import Vapor
import App

public struct SQLiteFactory: DatabaseFactory {
    public let databaseId: DatabaseID = .sqlite

    public func configure(_ app: Application) {
        app.databases.use(.sqlite(.init(storage: .memory)), as: .sqlite, isDefault: true)
    }
}
