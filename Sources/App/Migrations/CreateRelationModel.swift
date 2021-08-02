import Fluent

struct CreateRelationModel: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(RelationModel.schema)
            .field("id", .int, .identifier(auto: true))
            .field("type", .string, .required)
            .field("from", .int, .required)
            .field("to", .int, .required)
            .field("data", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(RelationModel.schema).delete()
    }
}
