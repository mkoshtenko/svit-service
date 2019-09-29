import Fluent

struct CreateRelation: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Relation.schema)
            .field("id", .int, .identifier(auto: true))
            .field("type", .string, .required)
            .field("from", .int, .required)
            .field("to", .int, .required)
            .field("data", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Relation.schema).delete()
    }
}
