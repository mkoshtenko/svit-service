import Fluent

struct CreateVertexModel: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(VertexModel.schema)
            .field("id", .int, .identifier(auto: true))
            .field("type", .string, .required)
            .field("data", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(VertexModel.schema).delete()
    }
}
