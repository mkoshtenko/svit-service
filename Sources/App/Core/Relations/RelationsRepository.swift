import Foundation

enum RelationsQuery {
    case relatedToVertex(VertexID)
}

protocol RelationsRepository: AnyObject {
    func findRelations(using: RelationsQuery, completion: @escaping RepositoryCompletion<[Relation]>)
    func deleteRelations(ids: [RelationID], completion: @escaping RepositoryCompletion<[RelationID]>)
}
