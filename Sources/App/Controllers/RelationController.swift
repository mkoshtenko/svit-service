import Vapor
import Fluent

struct RelationController {
    func create(req: Request) throws -> EventLoopFuture<Relation> {
        // TODO: Add validation for Relation with Validatable protocol

        let relation = try req.content.decode(Relation.self)
        return Vertex.find(relation.from, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "\(Vertex.self).id=\(relation.from) not found"))
            .flatMap { _ in Vertex.find(relation.to, on: req.db) }
            .unwrap(or: Abort(.notFound, reason: "\(Vertex.self).id=\(relation.to) not found"))
            .flatMap { _ in relation.save(on: req.db) }
            .flatMap { _ in RelationCount.incrementCount(vertexId: relation.from, type: relation.type, on: req.db) }
            .map { relation }
    }

    func update(req: Request) throws -> EventLoopFuture<Relation> {
        // TODO: Add validation for Relation with Validatable protocol

        guard let data = try req.content.decode([String: String].self)["data"] else {
            throw Abort(.badRequest, reason: "'data' field is missing")
        }

        let relationId: Int? = req.parameters.get(Path.Relations.id)
        return Relation.find(relationId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { relation in
                relation.data = data
                return relation.update(on: req.db).map { relation }
        }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let relationId: Int? = req.parameters.get(Path.Relations.id)
        return Relation.find(relationId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { relation in relation.delete(on: req.db).map { relation } }
            .flatMap { relation in RelationCount.decrementCount(vertexId: relation.from, type: relation.type, on: req.db) }
            .map { .ok }
    }
}

// TODO: remove these methods, they are for debugging only
extension RelationController {
    func list(req: Request) throws -> EventLoopFuture<[Relation]> {
        return Relation.query(on: req.db).all()
    }

    func get(req: Request) throws -> EventLoopFuture<Relation> {
        let relationId: Int? = req.parameters.get(Path.Relations.id)
        return Relation.find(relationId, on: req.db)
            .unwrap(or: Abort(.notFound))
    }
}
