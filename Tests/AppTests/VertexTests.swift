import XCTest
import XCTVapor

@testable import App

final class VertexTests: XCTVaporTestCase {

    func testAddAndDeleteVertex() throws {
        let vertex1 = Vertex(id: 1, type: "type1", data: "")
        let vertex2 = Vertex(id: 2, type: "type2", data: "")

        try app.test(.GET, "/vertices") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "[]")
        }.test(.POST, "/vertices", json: vertex1) { res in
            // Create first vertex
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, vertex1)
        }.test(.GET, "/vertices/\(vertex1.id!)") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, vertex1)
        }.test(.POST, "/vertices", json: vertex2) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, vertex2)
        }.test(.GET, "/vertices/\(vertex2.id!)") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, vertex2)
        }.test(.GET, "/vertices") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, [vertex1, vertex2])
        }.test(.DELETE, "/vertices/\(vertex2.id!)") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/vertices/\(vertex2.id!)") { res in
            XCTAssertEqual(res.status, .notFound)
        }.test(.DELETE, "/vertices/\(vertex1.id!)") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/vertices/\(vertex1.id!)") { res in
            XCTAssertEqual(res.status, .notFound)
        }.test(.GET, "/vertices") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "[]")
        }
    }

    func testVertexUpdate() throws {
        let json = String(data: try JSONEncoder().encode(["a": "b"]), encoding: .utf8)
        let vertex = Vertex(id: 1, type: "type", data: "")
        try app.test(.POST, "/vertices", json: vertex) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, vertex)
        }.test(.PATCH, "/vertices/\(vertex.id!)", json: ["data": json, "type": "new"]) { res in
            XCTAssertEqual(res.status, .ok)
            let decoded = res.vertex
            XCTAssertNotNil(decoded)
            XCTAssertEqual(decoded?.type, vertex.type, "Value shoud be equal to original")
            XCTAssertEqual(decoded?.data, json, "Data field should be replaced with the new one")
        }.test(.PATCH, "/vertices/\(vertex.id!)", json: ["a": "b"]) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testDeleteVertexWithRelationTo() throws {
        let vertexToId = 2

        try app.prepare {
            try Vertex(id: 1, type: "t", data: "").save(on: db).wait()
            try Vertex(id: vertexToId, type: "t", data: "").save(on: db).wait()
            try Relation(id: 1, type: "t", from: 1, to: vertexToId, data: "").save(on: db).wait()
        }.test(.DELETE, "/vertices/\(vertexToId)") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/vertices/\(vertexToId)") { res in
            XCTAssertEqual(res.status, .notFound)
        }.test(.GET, "/vertices/\(1)") { res in
            XCTAssertEqual(res.status, .ok)
            // Verify relation was deleted
            XCTAssertEqual(try Vertex.query(on: db).all().wait().count, 1)
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
