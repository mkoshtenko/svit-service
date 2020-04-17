import Vapor
import Fluent

final class Relation: Model, Content {
    static let schema = "relations"

    @ID(custom: "id")
    var id: Int?

    @Field(key: "type")
    var type: String

    @Field(key: "from")
    var from: Int

    @Field(key: "to")
    var to: Int

    @Field(key: "data")
    var data: String

    init() { }

    init(id: Int? = nil, type: String, from: Int, to: Int, data: String) {
        self.id = id
        self.type = type
        self.from = from
        self.to = to
        self.data = data
    }
}

extension Relation {
    /**
     This structure is used for update requests

     When Relation entity is created we cannot change its 'type', 'id', 'from' or 'to' fields,
     therefore we use this structure with only the data field required.
     */
    struct Update: Content {
        var data: String
    }
}

extension Relation: Equatable {
    static func == (lhs: Relation, rhs: Relation) -> Bool {
        guard lhs !== rhs else { return true }
        return lhs.id == rhs.id
            && lhs.type == rhs.type
            && lhs.from == rhs.from
            && lhs.to == rhs.to
            && lhs.data == rhs.data
    }
}

extension Relation: Validatable {
    /**
     This method contains common validations for create requests.
     */
    static func validations(_ validations: inout Validations) {
        // The type is a string and should not be empty when creating new entity.
        validations.add("type", is: .alphanumeric && !.empty)
    }
}
