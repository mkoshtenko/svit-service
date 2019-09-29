import Vapor
import Fluent

final class Relation: Model, Content {
    static let schema = "relations"

    @ID(key: "id")
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
