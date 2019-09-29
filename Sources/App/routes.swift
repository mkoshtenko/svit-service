import Fluent
import Vapor
import PostgresKit

func routes(_ r: Routes, _ c: Container) throws {
    r.get("health") { req in
        return "{ \"status\": \"UP\" }"
    }

    try VertexController(db: c.make()).connect(r)
    try RelationController(db: c.make()).connect(r)
}

extension VertexController {
    func connect(_ r: Routes) {
        r.get(Path.vertices, use: list)
        r.post(Path.vertices, use: create)
        r.get(Path.vertices, .parameter(Path.vertexId), use: get)
        r.delete(Path.vertices, .parameter(Path.vertexId), use: delete)
        r.patch(Path.vertices, .parameter(Path.vertexId), use: update)
    }
}

extension RelationController {
    func connect(_ r: Routes) {
        r.get(Path.relations, use: list)
        r.post(Path.relations, use: create)
        r.get(Path.relations, .parameter(Path.relationId), use: get)
        r.delete(Path.relations, .parameter(Path.relationId), use: delete)
        r.patch(Path.relations, .parameter(Path.relationId), use: update)
    }
}
