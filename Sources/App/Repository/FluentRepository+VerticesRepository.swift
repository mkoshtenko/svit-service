import Fluent

extension FluentRepository: VerticesRepository {
    func makeVertex(type: String, data: String, completion: @escaping RepositoryCompletion<Vertex>) {
        let model = VertexModel(type: type, data: data)
        model.save(on: db)
            .map { model }
            .whenComplete { result in
                completion(Result(catching: { try result.getVertex() }))
            }
    }

    func getVertex(with id: VertexID, completion: @escaping RepositoryCompletion<Vertex>) {
        VertexModel.find(id, on: db)
            .unwrap(or: RepositoryError.notFound)
            .whenComplete { result in
                completion(Result(catching: { try result.getVertex() }))
            }
    }

    func updateVertex(with id: VertexID, newData: String, completion: @escaping RepositoryCompletion<Vertex>) {
        VertexModel.find(id, on: db)
            .unwrap(or: RepositoryError.notFound)
            .flatMap { model in
                model.data = newData
                return model.update(on: self.db).map { model }
            }.whenComplete { result in
                completion(Result(catching: { try result.getVertex() }))
            }
    }

    func deleteVertex(with id: VertexID, completion: @escaping RepositoryCompletion<Vertex>) {
        VertexModel.find(id, on: db)
            .unwrap(or: RepositoryError.notFound)
            .flatMap { model in
                model.delete(on: self.db).map { model }
            }.whenComplete { result in
                completion(Result(catching: { try result.getVertex() }))
            }
    }
}

private extension Result where Failure == RepositoryError {
    init(catching body: () throws -> Success) {
        do {
            self = .success(try body())
        } catch let error as RepositoryError {
            self = .failure(error)
        } catch {
            self = .failure(.generic(error))
        }
    }
}

private extension Result where Success == VertexModel {
    func getVertex() throws -> Vertex {
        switch self {
        case .success(let value):
            return try value.vertex()
        case .failure(let error):
            throw error
        }
    }
}

private extension VertexModel {
    func vertex() throws -> Vertex {
        guard let vertexID = id else { throw RepositoryError.entityNotCreated }
        return Vertex(id: vertexID, type: type, data: data)
    }
}
