import Fluent
import FluentPostgresDriver
import Vapor
import App

public struct PSQLFactory: DatabaseFactory {
    public let databaseId: DatabaseID = .psql

    public func configure(_ app: Application) {
        app.databases.postgres(configuration: configuration,
                               poolConfiguration: app.make(),
                               on: app.make())
    }

    private var configuration: PostgresConfiguration {
        return .init(hostname: Environment.db.host,
                     port: Environment.db.port,
                     username: Environment.db.user,
                     password: Environment.db.password,
                     database: Environment.db.name)
    }
}

private extension Environment {
    static let db = DatabaseConfig.self

    struct DatabaseConfig {
        static var host: String {
            return get("SVIT_DB_HOST") ?? "127.0.0.1"
        }

        static var port: Int {
            return get("SVIT_DB_PORT").flatMap { Int($0) } ?? 54320
        }

        static var name: String {
            return get("SVIT_DB_NAME") ?? "svit_db"
        }

        static var password: String {
            return get("SVIT_DB_PASSWORD") ?? "password"
        }

        static var user: String {
            return get("SVIT_DB_USER") ?? "svit_db_user"
        }
    }
}
