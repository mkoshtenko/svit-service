import Fluent
import Vapor

public protocol DatabaseFactory {
    var databaseId: DatabaseID { get }
    func configure(_ s: inout Services)
}

public protocol HasDatabaseFactory {
    var databaseFactory: DatabaseFactory { get }
}

extension Services {
    mutating func registerDatabase(_ factory: DatabaseFactory) {
        factory.configure(&self)
    }

    mutating func registerMigrations(_ factory: DatabaseFactory, _ handler: @escaping () -> [Migration]) {
        register(Migrations.self) { c in
            var migrations = Migrations()
            for migration in handler() {
                migrations.add(migration, to: factory.databaseId)
            }
            return migrations
        }
    }
}
