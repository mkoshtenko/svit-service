import Foundation

enum VerticesServiceError: Error {
    case vertexNotFound
}

typealias VertexResult = Result<Vertex, VerticesServiceError>

protocol VerticesService: AnyObject {
    func createVertex(type: String, data: String, completion: @escaping (VertexResult) -> Void)
    func getVertex(withID: VertexID, completion: @escaping (VertexResult) -> Void)
    func updateVertex(withID: VertexID, newData: String, completion: @escaping (VertexResult) -> Void)
    func deleteVertex(withID: VertexID, completion: @escaping (VertexResult) -> Void)
}
