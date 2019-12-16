import Fluent

struct CreateRelationCount: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(RelationCount.schema)
            .field("id", .int, .identifier(auto: true))
            .field("type", .string, .required)
            .field("from", .int, .required)
            .field("value", .int, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(RelationCount.schema).delete()
    }
}
