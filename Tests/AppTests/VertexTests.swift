import XCTest
import XCTVapor

@testable import App

final class VertexTests: XCTVaporTestCase {

    func testCreateVertex() throws {
        try app.test(.POST, "/vertices", json: Vertex(type: "a", data: "{}")) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, Vertex(id: 1, type: "a", data: "{}"))
        }.test(.POST, "/vertices", json: Vertex(type: "", data: "")) { res in
            XCTAssertEqual(res.status, .internalServerError, "Does not accept empty type")
        }
    }

    func testAddAndDeleteVertex() throws {
        let vertex1 = Vertex(type: "type1", data: "")
        let vertex2 = Vertex(type: "type2", data: "")
        
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
        let vertex = Vertex(type: "type", data: "")
        try app.test(.POST, "/vertices", json: vertex) { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.PATCH, "/vertices/\(1)", json: ["data": json, "type": "new"]) { res in
            XCTAssertEqual(res.status, .ok)
            let decoded = res.vertex
            XCTAssertNotNil(decoded)
            XCTAssertEqual(decoded?.type, vertex.type, "Value shoud be equal to original")
            XCTAssertEqual(decoded?.data, json, "Data field should be replaced with the new one")
        }.test(.PATCH, "/vertices/\(1)", json: ["a": "b"]) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func testDeleteVertexWithRelations() throws {
        let vertexId = 2
        
        try app.prepare {
            try Vertex(id: 1, type: "t", data: "").save(on: db).wait()
            try Vertex(id: vertexId, type: "t", data: "").save(on: db).wait()
            try Relation(id: 1, type: "t1", from: 1, to: vertexId, data: "").save(on: db).wait()
            try Relation(id: 2, type: "t2", from: vertexId, to: 1, data: "").save(on: db).wait()
        }.test(.DELETE, "/vertices/\(vertexId)") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/vertices/\(vertexId)") { res in
            XCTAssertEqual(res.status, .notFound)
            // Verify relation was deleted
            XCTAssertEqual(try Relation.query(on: db).all().wait().count, 0)
        }
    }    
}

private extension XCTHTTPResponse {
    var vertex: Vertex? {
        guard let data = body.data else { return nil }
        return try? JSONDecoder().decode(Vertex.self, from: data)
    }
}
