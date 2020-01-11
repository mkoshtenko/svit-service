import Vapor
import Fluent

struct VertexController {
    // TODO: remove list method
    func list(req: Request) throws -> EventLoopFuture<[Vertex]> {
        return Vertex.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Vertex> {
        // TODO: Add validation for Vertex with Validatable protocol
//        let decoder = try URLEncodedFormDecoder().decode(DecoderUnwrapper.self, from: req.url)
//        try Vertex.validate(decoder.decoder)

        let vertex = try req.content.decode(Vertex.self)
        return vertex.save(on: req.db).map { vertex }
    }

    func get(req: Request) throws -> EventLoopFuture<Vertex> {
        let vertexId: Int? = req.parameters.get(Path.Vertices.id)
        return Vertex.find(vertexId, on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let vertexId: Int = req.parameters.get(Path.Vertices.id) else {
            throw Abort(.badRequest, reason: "Cannot find 'vertexId' in the path")
        }

        return Vertex.find(vertexId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .deleteWithAllRelations(on: req.db)
            .map { .ok }
    }

    func update(req: Request) throws -> EventLoopFuture<Vertex> {
        guard let data = try req.content.decode([String: String].self)["data"] else {
            throw Abort(.badRequest, reason: "'data' field is missing")
        }

        let vertexId: Int? = req.parameters.get(Path.Vertices.id)
        return Vertex.find(vertexId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { vertex in
                vertex.data = data
                return vertex.update(on: req.db).map { vertex }
        }
    }
}

private extension EventLoopFuture where Value == Vertex {
    func deleteWithAllRelations(on database: Database) -> EventLoopFuture<Void> {
        // TODO: refactor and add transaction
        return self.flatMap { vertex in
            vertex.delete(on: database).map { vertex.id }
        }
        .unwrap(or: Abort(.notFound))
        .flatMap { id in
            Relation.query(on: database)
                .filter(\.$to == id)
                .delete()
                .map { id }
        }
        .flatMap { id in
            Relation.query(on: database)
                .filter(\.$from == id)
                .delete()
        }
    }
}
