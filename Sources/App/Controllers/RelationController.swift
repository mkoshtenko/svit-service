import Vapor
import Fluent

final class RelationController {
    enum Path {
        static let relations: PathComponent = "relations"
        static let relationId = "relation_id"
    }

    let db: Database

    init(db: Database) {
        self.db = db
    }

    // TODO: remove list method
    func list(req: Request) throws -> EventLoopFuture<[Relation]> {
        return Relation.query(on: db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Relation> {
        let relation = try req.content.decode(Relation.self)
        return Vertex.find(relation.from, on: db)
            .unwrap(or: Abort(.notFound, reason: "\(Vertex.self).id=\(relation.from) not found"))
            .flatMap { _ in Vertex.find(relation.to, on: self.db) }
            .unwrap(or: Abort(.notFound, reason: "\(Vertex.self).id=\(relation.to) not found"))
            .flatMap { _ in relation.save(on: self.db) }
            .map { relation }
    }

    func get(req: Request) throws -> EventLoopFuture<Relation> {
        let relationId: Int? = req.parameters.get(Path.relationId)
        return Relation.find(relationId, on: db)
            .unwrap(or: Abort(.notFound))
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let relationId: Int? = req.parameters.get(Path.relationId)
        return Relation.find(relationId, on: db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: self.db) }
            .transform(to: .ok)
    }

    func update(req: Request) throws -> EventLoopFuture<Relation> {
        guard let data = try req.content.decode([String: String].self)["data"] else {
            throw Abort(.badRequest, reason: "'data' field is missing")
        }

        let relationId: Int? = req.parameters.get(Path.relationId)
        return Relation.find(relationId, on: db)
            .unwrap(or: Abort(.notFound))
            .flatMap { relation in
                relation.data = data
                return relation.update(on: self.db).map { relation }
        }
    }

}
