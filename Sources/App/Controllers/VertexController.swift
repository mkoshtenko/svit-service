import Vapor
import Fluent

struct VertexController {
    enum Path {
        static let vertices: PathComponent = "vertices"
        static let vertexId = "vertex_id"
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
        let vertexId: Int? = req.parameters.get(Path.vertexId)
        // TODO: Refactor delete. Preferrably the should be single transaction.
        return Vertex.find(vertexId, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { vertex in
                vertex.delete(on: req.db).map { vertex }

        }
        .flatMap { vertex in
            Relation.query(on: req.db)
                .filter(\.$to == vertex.id!)
                .all()
                .map {
                    $0.map {
                        $0.delete(on: req.db)
                    }
            }

        }
        .transform(to: .ok)
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
}
