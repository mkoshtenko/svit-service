import XCTest
import XCTVapor

@testable import App

final class VertexTests: XCTVaporTestCase {

    func testCreateVertexModel() throws {
        try app.test(.POST, "/vertices", json: ["type": "a", "data": "{}"]) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, VertexModel(id: 1, type: "a", data: "{}"))
        }.test(.POST, "/vertices", json: VertexModel(type: "", data: "")) { res in
            XCTAssertEqual(res.status, .badRequest, "Does not accept empty type")
        }
    }

    func testAddAndDeleteVertexModel() throws {
        let vertex1 = VertexModel(type: "type1", data: "")
        let vertex2 = VertexModel(type: "type2", data: "")

        try app.test(.GET, "/vertices") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "[]")
        }.test(.POST, "/vertices", json: vertex1) { res in
            // Create first vertex
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/vertices/\(1)") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.POST, "/vertices", json: vertex2) { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/vertices/\(2)") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/vertices") { res in
            XCTAssertEqual(res.status, .ok)
            // todo: test the body contains two objects
        }.test(.DELETE, "/vertices/\(2)") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/vertices/\(2)") { res in
            XCTAssertEqual(res.status, .notFound)
        }.test(.DELETE, "/vertices/\(1)") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/vertices/\(1)") { res in
            XCTAssertEqual(res.status, .notFound)
        }.test(.GET, "/vertices") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "[]")
        }
    }

    func testVertexUpdate() throws {
        let json = String(data: try JSONEncoder().encode(["a": "b"]), encoding: .utf8)
        let vertex = VertexModel(type: "type", data: "")
        try app.test(.POST, "/vertices", json: vertex) { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.PATCH, "/vertices/notId", json: ["data": json]) { res in
            XCTAssertEqual(res.status, .badRequest)
        }.test(.PATCH, "/vertices/\(1)", json: ["data": json, "type": "new"]) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContent(VertexModel.self, res) { content in
                XCTAssertEqual(content.type, vertex.type, "Value shoud be equal to original")
                XCTAssertEqual(content.data, json, "Data field should be replaced with the new one")
            }
        }.test(.PATCH, "/vertices/\(1)", json: ["a": "b"]) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testDeleteVertexWithRelations() throws {
        let vertexId = 2

        try app.prepare { db in
            try VertexModel(id: 1, type: "t", data: "").save(on: db).wait()
            try VertexModel(id: vertexId, type: "t", data: "").save(on: db).wait()
            try RelationModel(id: 1, type: "t1", from: 1, to: vertexId, data: "").save(on: db).wait()
            try RelationModel(id: 2, type: "t2", from: vertexId, to: 1, data: "").save(on: db).wait()
        }.test(.DELETE, "/vertices/notId") { res in
            XCTAssertEqual(res.status, .badRequest)
        }.test(.DELETE, "/vertices/\(vertexId)") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/vertices/\(vertexId)") { res in
            XCTAssertEqual(res.status, .notFound)
            // Verify relation was deleted
            XCTAssertEqual(try RelationModel.query(on: db).all().wait().count, 0)
        }
    }
}
