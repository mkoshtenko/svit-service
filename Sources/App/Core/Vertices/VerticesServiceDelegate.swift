import Foundation

protocol VerticesServiceDelegate {
    func deleteRelations(for: VertexID, handler: @escaping RepositoryCompletion<[RelationID]>)
}
