import Fluent
import Vapor

public protocol DatabaseFactory {
    var databaseId: DatabaseID { get }
    func configure(_ app: Application)
}

public protocol HasDatabaseFactory {
    var databaseFactory: DatabaseFactory { get }
}

extension Application {
    func registerDatabase(_ factory: DatabaseFactory) {
        factory.configure(self)
    }

    func registerMigrations(_ factory: DatabaseFactory, _ handler: @escaping () -> [Migration]) {
        register(Migrations.self) { c in
            var migrations = Migrations()
            for migration in handler() {
                migrations.add(migration, to: factory.databaseId)
            }
            return migrations
        }
    }
}
