import Fluent
import Vapor

final class Vertex: Model, Content {
    static let schema = "vertices"
    
    @ID(key: "id")
    var id: Int?

    @Field(key: "type")
    var type: String

    @Field(key: "data")
    var data: String

    init() { }

    init(id: Int? = nil, type: String, data: String) {
        self.id = id
        self.type = type
        self.data = data
    }
}

extension Vertex: Equatable {
    static func == (lhs: Vertex, rhs: Vertex) -> Bool {
        guard lhs !== rhs else { return true }
        return lhs.id == rhs.id && lhs.type == rhs.type && lhs.data == rhs.data
    }
}

extension Vertex: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("type", is: .alphanumeric && !.empty)
    }
}
