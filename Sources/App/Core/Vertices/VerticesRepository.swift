import Foundation

protocol VerticesRepository: AnyObject {
    func createVertex(type: String, data: String, completion: @escaping RepositoryCompletion<Vertex>)
    func getVertex(with id: VertexID, completion: @escaping RepositoryCompletion<Vertex>)
    func updateVertex(with id: VertexID, newData: String, completion: @escaping RepositoryCompletion<Vertex>)
    // Returns deleted vertex instance if the operation was successful
    func deleteVertex(with id: VertexID, completion: @escaping RepositoryCompletion<Vertex>)
}
