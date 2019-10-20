import FluentPostgresDriver
import Vapor
import App

public struct PSQLFactory: DatabaseFactory {
    public let databaseId: DatabaseID = .psql

    public func configure(_ s: inout Services) {
        s.extend(Databases.self) { dbs, c in
            try dbs.postgres(config: c.make())
        }

        s.register(PostgresConfiguration.self) { c in
            return .init(hostname: Environment.db.host,
                         port: Environment.db.port,
                         username: Environment.db.user,
                         password: Environment.db.password,
                         database: Environment.db.name)
        }

        s.register(Database.self) { c in
            return try c.make(Databases.self).database(.psql)!
        }
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
