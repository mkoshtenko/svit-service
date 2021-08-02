import Foundation

protocol RelationsServiceDelegate {
    func didCreateRelationModel(id: VertexID)
    func didDeleteRelationModel(id: VertexID)
}
