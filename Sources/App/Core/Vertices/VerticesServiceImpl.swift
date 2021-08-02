import Foundation

final class VerticesServiceImpl: VerticesService {
    private let repository: VerticesRepository
    private let delegate: VerticesServiceDelegate

    init(repository: VerticesRepository, delegate: VerticesServiceDelegate) {
        self.repository = repository
        self.delegate = delegate
    }

    func createVertex(type: String, data: String, completion: @escaping (VertexResult) -> Void) {
        repository.createVertex(type: type, data: data) { result in
            completion(result.mapError(\.verticesServiceError))
        }
    }

    func getVertex(withID id: VertexID, completion: @escaping (VertexResult) -> Void) {
        repository.getVertex(with: id) { result in
            completion(result.mapError(\.verticesServiceError))
        }
    }

    func updateVertex(withID id: VertexID, newData: String, completion: @escaping (VertexResult) -> Void) {
        repository.updateVertex(with: id, newData: newData) { result in
            completion(result.mapError(\.verticesServiceError))
        }
    }

    func deleteVertex(withID id: VertexID, completion: @escaping (VertexResult) -> Void) {
        repository.deleteVertex(with: id) { result in
            self.delegate.deleteRelations(for: id) { results in
                // TODO: log errors
                completion(result.mapError(\.verticesServiceError))
            }
        }
    }
}

private extension RepositoryError {
    var verticesServiceError: VerticesServiceError {
        // TODO: log the error
        .vertexNotFound
    }
}
