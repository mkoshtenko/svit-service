import Vapor
import Fluent

struct VertexController {
    enum Path {
        static let vertices: PathComponent = "vertices"
        static let vertexId = "vertex_id"
        static let relationType = "type"
        static let count: PathComponent = "count"
    }

    // TODO: remove list method
    func list(req: Request) throws -> EventLoopFuture<[Vertex]> {
        return Vertex.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Vertex> {
        let vertex = try req.content.decode(Vertex.self)
        return vertex.save(on: req.db).map { vertex }
    }

    func get(req: Request) throws -> EventLoopFuture<Vertex> {
        let vertexId: Int? = req.parameters.get(Path.vertexId)
        return Vertex.find(vertexId, on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        guard let vertexId: Int = req.parameters.get(Path.vertexId) else {
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

        let vertexId: Int? = req.parameters.get(Path.vertexId)
        return Vertex.find(vertexId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { vertex in
                vertex.data = data
                return vertex.update(on: req.db).map { vertex }
        }
    }

    func relationsCount(req: Request) throws -> EventLoopFuture<RelationCount> {
        guard let vertexId: Int = req.parameters.get(Path.vertexId) else {
            throw Abort(.badRequest, reason: "vertex id is not found")
        }

        guard let type: String = req.parameters.get(Path.relationType) else {
            throw Abort(.badRequest, reason: "relation type is not found")
        }

        return RelationCount.query(vertexId: vertexId, type: type, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "No relations for vertex with id \(vertexId)"))
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
