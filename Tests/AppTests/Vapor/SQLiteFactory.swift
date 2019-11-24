import FluentSQLiteDriver
import Fluent
import Vapor
import App

public struct SQLiteFactory: DatabaseFactory {
    static let filePath = "tests.sqlite"

    public let databaseId: DatabaseID = .sqlite

    public func configure(_ app: Application) {
        app.databases.sqlite(
            configuration: configuration,
            threadPool: app.make(),
            on: app.make()
        )
    }

    private var configuration: SQLiteConfiguration {
        return .init(storage: .connection(.file(path: SQLiteFactory.filePath)))
    }
}
