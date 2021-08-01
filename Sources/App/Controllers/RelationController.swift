import Vapor
import Fluent

struct RelationController {
    /**
     For now `to` and `type` are mutually exclusive, only one of them can be used at the time.
     */
    struct Query: Codable {
        let from: Int
        let to: Int?
        let type: String?
    }

    func getFromVertexModel(req: Request) throws -> EventLoopFuture<[Relation]> {
        let query = try req.query.decode(Query.self)
        return try Relation.find(fromId: query.from, toId: query.to, type: query.type, on: req.db)
    }

    func create(req: Request) throws -> EventLoopFuture<Relation> {
        try Relation.validate(req)
        let relation = try req.content.decode(Relation.self)
        return VertexModel.find(relation.from, on: req.db)
            .unwrap(or: Abort(.notFound, reason: "\(VertexModel.self).id=\(relation.from) not found"))
            .flatMap { _ in VertexModel.find(relation.to, on: req.db) }
            .unwrap(or: Abort(.notFound, reason: "\(VertexModel.self).id=\(relation.to) not found"))
            .flatMap { _ in relation.save(on: req.db) }
            .flatMap { _ in RelationCount.incrementCount(vertexId: relation.from, type: relation.type, on: req.db) }
            .map { relation }
    }

    func update(req: Request) throws -> EventLoopFuture<Relation> {
        let relationId = try req.parameters.unwrapRelationId()
        let relationUpdate = try req.content.decode(Relation.Update.self)

        return Relation.find(relationId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { relation in
                relation.data = relationUpdate.data
                return relation.update(on: req.db).map { relation }
        }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let relationId = try req.parameters.unwrapRelationId()
        return Relation.find(relationId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { relation in relation.delete(on: req.db).map { relation } }
            .flatMap { relation in RelationCount.decrementCount(vertexId: relation.from, type: relation.type, on: req.db) }
            .map { .ok }
    }
}

// TODO: remove these methods, they are for debugging only
extension RelationController {
    func get(req: Request) throws -> EventLoopFuture<Relation> {
        let relationId = try req.parameters.unwrapRelationId()
        return Relation.find(relationId, on: req.db)
            .unwrap(or: Abort(.notFound))
    }
}

private extension Relation {
    static func find(fromId: Int, toId: Int?, type: String?, on db: Database) throws -> EventLoopFuture<[Relation]> {
        guard toId != nil || type != nil else {
            throw Abort(.badRequest, reason: "'to' XOR 'type' must be added to the request")
        }

        // Relations can be filtered with either toId or type, both are not allowed
        guard (toId == nil && type != nil) || (toId != nil && type == nil) else {
            throw Abort(.badRequest, reason: "'to' and 'type' are mutually exclusive")
        }
        return VertexModel.find(fromId, on: db)
            .unwrap(or: Abort(.notFound, reason: "Vertex with id \(fromId) not found"))
            .flatMap { _ in
                let query = Relation.query(on: db)
                    .filter(\.$from == fromId)

                if let type = type {
                    query.filter(\.$type == type)
                }

                if let to = toId {
                    query.filter(\.$to == to)
                }

                return query.all()
        }
    }
}

private extension Parameters {
    func unwrapRelationId() throws -> Relation.IDValue {
        guard let id: Relation.IDValue = get(Path.Relations.id) else {
            throw Abort(.badRequest, reason: "Cannot find 'relationId' in the path")
        }
        return id
    }
}
