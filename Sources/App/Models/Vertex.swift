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

extension Vertex {
    /**
     This structure is used for update requests

     After a Vertex is created we cannot change its type or id therefore we use this structure with only data field
     */
    struct Update: Content {
        var data: String
    }
}

extension Vertex: Equatable {
    static func == (lhs: Vertex, rhs: Vertex) -> Bool {
        guard lhs !== rhs else { return true }
        return lhs.id == rhs.id && lhs.type == rhs.type && lhs.data == rhs.data
    }
}

extension Vertex: Validatable {
    /**
     This method contains common validations for entity's create request.
     */
    static func validations(_ validations: inout Validations) {
        // Does not accept an id from create request
        validations.add("id", is: Validator<Optional<Int>>.nil)

        // The type is a string and should not be empty when creating new entity.
        validations.add("type", is: .alphanumeric && !.empty)
    }
}
