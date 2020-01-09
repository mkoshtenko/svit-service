import Vapor
import Fluent

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
        return query(vertexId: vertexId, type: type, on: db)
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

    static func query(vertexId: Int, type: String, on db: Database) -> EventLoopFuture<RelationCount?> {
        return Vertex.find(vertexId, on: db)
            .unwrap(or: Abort(.notFound, reason: "Vertex with id \(vertexId) not found"))
            .flatMap { _ in
                return RelationCount.query(on: db)
                    .filter(\.$from == vertexId)
                    .filter(\.$type == type)
                    .first()
        }
    }
}
