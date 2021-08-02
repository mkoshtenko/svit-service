import Foundation

enum RelationsServiceError: Error {
    case relationNotFound
}

typealias RelationResult = Result<Relation, RelationsServiceError>

protocol RelationsService: AnyObject {
    func findRelations(from: VertexID, to: VertexID?, type: String?, completion: @escaping (RelationResult) -> Void)
    func createRelation(from: VertexID, to: VertexID, type: String, data: String, completion: @escaping (RelationResult) -> Void)
    func updateRelation(id: RelationID, newData: String, completion: @escaping (RelationResult) -> Void)
    func deleteRelation(id: RelationID, completion: @escaping (RelationResult) -> Void)
}
