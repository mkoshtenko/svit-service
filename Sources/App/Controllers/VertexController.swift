import Vapor
import Fluent

struct VertexController {
    func get(req: Request) throws -> EventLoopFuture<Vertex> {
        let vertexId: Int? = req.parameters.get(Path.Vertices.id)
        return Vertex.find(vertexId, on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func create(req: Request) throws -> EventLoopFuture<Vertex> {
        try Vertex.validate(req)
        let vertex = try req.content.decode(Vertex.self)
        return vertex.save(on: req.db).map { vertex }
    }

    func update(req: Request) throws -> EventLoopFuture<Vertex> {
        let vertexId = try req.parameters.unwrapVertexId()
        let vertexUpdate = try req.content.decode(Vertex.Update.self)

        return Vertex.find(vertexId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { vertex in
                vertex.data = vertexUpdate.data
                return vertex.update(on: req.db).map { vertex }
        }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let vertexId = try req.parameters.unwrapVertexId()

        return Vertex.find(vertexId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .deleteWithAllRelations(on: req.db)
            .map { .ok }
    }
}

private extension Parameters {
    func unwrapVertexId() throws -> Vertex.IDValue {
        guard let vertexId: Vertex.IDValue = get(Path.Vertices.id) else {
            throw Abort(.badRequest, reason: "Cannot find 'vertexId' in the path")
        }
        return vertexId
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

// TODO: remove these debug methods
extension VertexController {
    func list(req: Request) throws -> EventLoopFuture<[Vertex]> {
        return Vertex.query(on: req.db).all()
    }
}
