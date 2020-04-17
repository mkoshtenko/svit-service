import Vapor
import Fluent

final class RelationCount: Model {
    static let schema = "count"

    @ID(custom: "id")
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

extension RelationCount: PublicConvertible {
    struct Public: Equatable, Content {
        let from: Int
        let type: String
        let count: Int
    }

    var publicContent: Public {
        return Public(from: from, type: type, count: value)
    }
}
