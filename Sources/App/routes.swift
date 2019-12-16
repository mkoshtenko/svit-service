import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get("health") { req in
        return "{ \"status\": \"UP\" }"
    }

    VertexController().connect(app)
    RelationController().connect(app)
}

extension VertexController {
    func connect(_ app: Application) {
        app.get(Path.vertices, use: list)
        app.post(Path.vertices, use: create)
        app.get(Path.vertices, .parameter(Path.vertexId), use: get)
        app.delete(Path.vertices, .parameter(Path.vertexId), use: delete)
        app.patch(Path.vertices, .parameter(Path.vertexId), use: update)

        app.get(Path.vertices, .parameter(Path.vertexId), Path.count, .parameter(Path.relationType), use: relationsCount)
    }
}

extension RelationController {
    func connect(_ app: Application) {
        app.get(Path.relations, use: list)
        app.post(Path.relations, use: create)
        app.get(Path.relations, .parameter(Path.relationId), use: get)
        app.delete(Path.relations, .parameter(Path.relationId), use: delete)
        app.patch(Path.relations, .parameter(Path.relationId), use: update)
    }
}
