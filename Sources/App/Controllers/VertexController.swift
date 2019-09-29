import Vapor
import Fluent

final class VertexController {
    enum Path {
        static let vertices: PathComponent = "vertices"
        static let vertexId = "vertex_id"
    }

    let db: Database

    init(db: Database) {
        self.db = db
    }

    // TODO: remove list method
    func list(req: Request) throws -> EventLoopFuture<[Vertex]> {
        return Vertex.query(on: db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Vertex> {
        let vertex = try req.content.decode(Vertex.self)
        return vertex.save(on: db).map { vertex }
    }

    func get(req: Request) throws -> EventLoopFuture<Vertex> {
        let vertexId: Int? = req.parameters.get(Path.vertexId)
        return Vertex.find(vertexId, on: db)
            .unwrap(or: Abort(.notFound))
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let vertexId: Int? = req.parameters.get(Path.vertexId)
        return Vertex.find(vertexId, on: db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: self.db) }
            .transform(to: .ok)
    }

    func update(req: Request) throws -> EventLoopFuture<Vertex> {
        guard let data = try req.content.decode([String: String].self)["data"] else {
            throw Abort(.badRequest, reason: "'data' field is missing")
        }

        let vertexId: Int? = req.parameters.get(Path.vertexId)
        return Vertex.find(vertexId, on: db)
            .unwrap(or: Abort(.notFound))
            .flatMap { vertex in
                vertex.data = data
                return vertex.update(on: self.db).map { vertex }
        }
    }
}
