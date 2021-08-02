import Foundation

typealias RelationID = Int

struct Relation {
    let id: RelationID
    let type: String
    let from: VertexID
    let to: VertexID
    let data: String
}
