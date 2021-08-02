import Vapor
import Fluent

struct VertexController {
    func get(req: Request) throws -> EventLoopFuture<VertexModel> {
        let id = try req.parameters.vertexID()
        return req.execute { vertices, handler in
            vertices.getVertex(withID: id, completion: handler)
        }
    }

    func create(req: Request) throws -> EventLoopFuture<VertexModel> {
        try VertexModel.validate(req)
        let model = try req.content.decode(VertexModel.self)
        return req.execute { vertices, handler in
            vertices.createVertex(type: model.type, data: model.data, completion: handler)
        }
    }

    func update(req: Request) throws -> EventLoopFuture<VertexModel> {
        let id = try req.parameters.vertexID()
        let update = try req.content.decode(VertexModel.Update.self)
        return req.execute { vertices, handler in
            vertices.updateVertex(withID: id, newData: update.data, completion: handler)
        }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let id = try req.parameters.vertexID()
        return req.execute { vertices, handler in
            vertices.deleteVertex(withID: id, completion: handler)
        }.map { _ in .ok }
    }
}

private extension Parameters {
    func vertexID() throws -> VertexModel.IDValue {
        guard let id: VertexModel.IDValue = get(Path.Vertices.id) else {
            throw Abort(.badRequest, reason: "The vertex id is missing in the path")
        }
        return id
    }
}

private extension EventLoopFuture where Value == VertexModel {
    func deleteWithAllRelations(on database: Database) -> EventLoopFuture<Void> {
        // TODO: refactor and add transaction
        return self.flatMap { vertex in
            vertex.delete(on: database).map { vertex.id }
        }
        .unwrap(or: Abort(.notFound))
        .flatMap { id in
            RelationModel.query(on: database)
                .filter(\.$to == id)
                .delete()
                .map { id }
        }
        .flatMap { id in
            RelationModel.query(on: database)
                .filter(\.$from == id)
                .delete()
        }
    }
}

// TODO: remove these debug methods
extension VertexController {
    func list(req: Request) throws -> EventLoopFuture<[VertexModel]> {
        return VertexModel.query(on: req.db).all()
    }
}

private extension Request {
    func execute(_ block: (VerticesService, @escaping (VertexResult) -> Void) -> Void) -> EventLoopFuture<VertexModel> {
        let promise = eventLoop.makePromise(of: VertexModel.self)
        let completion: (VertexResult) -> Void = { result in
            let promiseResult: Result<VertexModel, Error> = result
                .map { VertexModel(vertex: $0) }
                .mapError { Abort($0) }
            promise.completeWith(promiseResult)
        }
        block(vertices, completion)
        return promise.futureResult
    }
}

private extension Abort {
    init(_ error: VerticesServiceError) {
        switch error {
        case .vertexNotFound:
            self.init(.notFound)
        }
    }
}

private extension VertexModel {
    convenience init(vertex: Vertex) {
        self.init(
            id: vertex.id,
            type: vertex.type,
            data: vertex.data
        )
    }
}
