import Foundation

final class RelationsServiceImpl: RelationsService {
    private let repository: RelationsRepository

    init(repository: RelationsRepository) {
        self.repository = repository
    }

    func findRelations(from: VertexID, to: VertexID?, type: String?, completion: @escaping (RelationResult) -> Void) {

    }

    func createRelation(from: VertexID, to: VertexID, type: String, data: String, completion: @escaping (RelationResult) -> Void) {

    }

    func updateRelation(id: RelationID, newData: String, completion: @escaping (RelationResult) -> Void) {

    }

    func deleteRelation(id: RelationID, completion: @escaping (RelationResult) -> Void) {
        
    }
}

extension RelationsServiceImpl: VerticesServiceDelegate {
    func deleteRelations(for id: VertexID, handler: @escaping RepositoryCompletion<[RelationID]>) {
        repository.findRelations(using: .relatedToVertex(id)) { result in
            switch result {
            case .success(let relations):
                self.repository.deleteRelations(ids: relations.map(\.id)) { results in
                    handler(results)
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
