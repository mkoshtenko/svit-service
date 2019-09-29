import Fluent

struct CreateVertex: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Vertex.schema)
            .field("id", .int, .identifier(auto: true))
            .field("type", .string, .required)
            .field("data", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Vertex.schema).delete()
    }
}
