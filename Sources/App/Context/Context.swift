import Vapor

public struct Context: HasDatabaseFactory & HasEnvironment {
    public let environment: Environment
    public let databaseFactory: DatabaseFactory

    public init(environment: Environment,
                databaseFactory: DatabaseFactory) {
        self.environment = environment
        self.databaseFactory = databaseFactory
    }
}
