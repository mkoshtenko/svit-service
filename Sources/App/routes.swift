import Fluent
import Vapor

enum Path {
    static let vertices: PathComponent = "vertices"
    enum Vertices {
        static let id = "vertex_id"
    }

    static let relations: PathComponent = "relations"
    enum Relations {
        static let id = "relation_id"
        static let to = "relation_to"
        static let from = "relation_from"
        static let type = "relation_type"
    }

    static let relationCount: PathComponent = "count"
}

func routes(_ app: Application) throws {
    app.get("health") { req in
        return "{ \"status\": \"UP\" }"
    }

    app.connect(VertexController())
    app.connect(RelationController())
    app.connect(RelationCountController())
}

extension Application {
    func connect(_ controller: VertexController) {
        get(Path.vertices, use: controller.list)
        post(Path.vertices, use: controller.create)
        get(Path.vertices, .parameter(Path.Vertices.id), use: controller.get)
        delete(Path.vertices, .parameter(Path.Vertices.id), use: controller.delete)
        patch(Path.vertices, .parameter(Path.Vertices.id), use: controller.update)
    }

    func connect(_ controller: RelationController) {
        get(Path.relations, use: controller.list)
        post(Path.relations, use: controller.create)
        get(Path.relations, .parameter(Path.Relations.id), use: controller.get)
        delete(Path.relations, .parameter(Path.Relations.id), use: controller.delete)
        patch(Path.relations, .parameter(Path.Relations.id), use: controller.update)
    }

    func connect(_ controller: RelationCountController) {
        get(Path.relationCount, use: controller.get)
    }
}
