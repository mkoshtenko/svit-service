import Vapor
import Fluent

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
