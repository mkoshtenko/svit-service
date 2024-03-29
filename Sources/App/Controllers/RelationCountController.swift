import Vapor
import Fluent

struct RelationCountController {
    struct Query: Codable {
        let from: Int
        let type: String
    }

    func get(req: Request) throws -> EventLoopFuture<RelationCount.Public> {
        let query = try req.query.decode(Query.self)
        return RelationCount.find(vertexId: query.from, type: query.type, on: req.db)
            // Returns public structure with `0` count if there are no relations found
            .convertToPublic(default: RelationCount.Public(from: query.from, type: query.type, count: 0))
    }
}

extension RelationCount {
    static func incrementCount(vertexId: Int, type: String, on db: Database) -> EventLoopFuture<Void> {
        return update(vertexId: vertexId, type: type, on: db) {
            return $0 + 1
        }
    }

    static func decrementCount(vertexId: Int, type: String, on db: Database) -> EventLoopFuture<Void> {
        return update(vertexId: vertexId, type: type, on: db) {
            return $0 - 1
        }
    }

    private static func update(vertexId: Int, type: String, on db: Database, map: @escaping (Int) -> Int) -> EventLoopFuture<Void> {
        return find(vertexId: vertexId, type: type, on: db)
            .flatMap { relationCount in
                if let count = relationCount {
                    count.value = map(count.value)
                    if count.value <= 0 {
                        return count.delete(on: db)
                    }
                    return count.update(on: db)
                }
                let count = RelationCount(type: type, from: vertexId, value: map(0))
                return count.save(on: db)
        }
    }

    static func find(vertexId: Int, type: String, on db: Database) -> EventLoopFuture<RelationCount?> {
        return VertexModel.find(vertexId, on: db)
            .unwrap(or: Abort(.notFound, reason: "Vertex with id \(vertexId) not found"))
            .flatMap { _ in
                return RelationCount.query(on: db)
                    .filter(\.$from == vertexId)
                    .filter(\.$type == type)
                    .first()
        }
    }
}
