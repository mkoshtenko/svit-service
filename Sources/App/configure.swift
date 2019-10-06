import Fluent
import FluentPostgresDriver
import Vapor

/// Called before your application initializes.
func configure(_ s: inout Services) {
    /// Register providers first
    s.provider(FluentProvider())

    /// Register routes
    s.extend(Routes.self) { r, c in
        try routes(r, c)
    }

    /// Register middleware
    s.register(MiddlewareConfiguration.self) { c in
        // Create _empty_ middleware config
        var middlewares = MiddlewareConfiguration()
        
        // Serves files from `Public/` directory
        /// middlewares.use(FileMiddleware.self)
        
        // Catches errors and converts to HTTP response
        try middlewares.use(c.make(ErrorMiddleware.self))
        
        return middlewares
    }
    
    s.extend(Databases.self) { dbs, c in
        try dbs.postgres(config: c.make())
    }

    s.register(PostgresConfiguration.self) { c in
        return .init(hostname: Environment.Database.host,
                     port: Environment.Database.port,
                     username: Environment.Database.user,
                     password: Environment.Database.password,
                     database: Environment.Database.name)
    }

    s.register(Database.self) { c in
        return try c.make(Databases.self).database(.psql)!
    }
    
    s.register(Migrations.self) { c in
        var migrations = Migrations()
        migrations.add(CreateVertex(), to: .psql)
        migrations.add(CreateRelation(), to: .psql)
        return migrations
    }
}

private extension Environment {
    struct Database {
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
