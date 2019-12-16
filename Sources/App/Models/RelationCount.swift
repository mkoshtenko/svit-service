import Vapor
import Fluent

final class RelationCount: Model, Content {
    static let schema = "count"

    @ID(key: "id")
    var id: Int?

    @Field(key: "type")
    var type: String

    @Field(key: "from")
    var from: Int

    @Field(key: "value")
    var value: Int

    init() { }

    init(id: Int? = nil, type: String, from: Int, value: Int) {
        self.id = id
        self.type = type
        self.from = from
        self.value = value
    }
}

extension RelationCount: Equatable {
    static func == (lhs: RelationCount, rhs: RelationCount) -> Bool {
        guard lhs !== rhs else { return true }
        return lhs.id == rhs.id
            && lhs.type == rhs.type
            && lhs.from == rhs.from
    }
}
