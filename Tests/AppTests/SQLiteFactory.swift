import FluentSQLiteDriver
import Vapor
import App

public struct SQLiteFactory: DatabaseFactory {
    static let filePath = "tests.sqlite"

    public let databaseId: DatabaseID = .sqlite

    public func configure(_ s: inout Services) {
        s.extend(Databases.self) { dbs, c in
            try dbs.sqlite(
                configuration: c.make(),
                threadPool: c.application.threadPool
            )
        }

        s.register(SQLiteConfiguration.self) { c in
            return .init(storage: .connection(.file(path: SQLiteFactory.filePath)))
        }

        s.register(Database.self) { c in
            return try c.make(Databases.self).database(.sqlite)!
        }
    }
}
