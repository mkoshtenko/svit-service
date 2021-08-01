import Foundation

protocol RelationsServiceDelegate {
    func didCreateRelation(id: VertexID)
    func didDeleteRelation(id: VertexID)
}
