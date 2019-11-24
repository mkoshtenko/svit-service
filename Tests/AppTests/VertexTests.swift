import XCTest

@testable import App


final class VertexTests: XCTVaporTestCase {
    func testAddAndDeleteVertex() throws {
        let vertex1 = Vertex(id: 1, type: "type1", data: "")
        let vertex2 = Vertex(id: 2, type: "type2", data: "")

        try app.testable()
            // Verify the are no vertices
            .test(.GET, "/vertices") { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqual(res.body.string, "[]")
        }
            // Create first vertex
            .test(.POST, "/vertices", json: vertex1) { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqualJSON(res.body.string, vertex1)
        }
            // Verify first vertex exists
            .test(.GET, "/vertices/\(vertex1.id!)") { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqualJSON(res.body.string, vertex1)
        }
            // Create second vertex
            .test(.POST, "/vertices", json: vertex2) { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqualJSON(res.body.string, vertex2)
        }
            // Verify second vertex exists
            .test(.GET, "/vertices/\(vertex2.id!)") { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqualJSON(res.body.string, vertex2)
        }
            // Get list
            .test(.GET, "/vertices") { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqualJSON(res.body.string, [vertex1, vertex2])
        }
            // Delete second vertex
            .test(.DELETE, "/vertices/\(vertex2.id!)") { res in
                XCTAssertEqual(res.status, .ok)
        }
            // Verify second vertex does not exists
            .test(.GET, "/vertices/\(vertex2.id!)") { res in
                XCTAssertEqual(res.status, .notFound)
        }
            // Delete first vertex
            .test(.DELETE, "/vertices/\(vertex1.id!)") { res in
                XCTAssertEqual(res.status, .ok)
        }
            // Verify first vertex does not exists
            .test(.GET, "/vertices/\(vertex1.id!)") { res in
                XCTAssertEqual(res.status, .notFound)
        }
            // Check the list is empty
            .test(.GET, "/vertices") { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqual(res.body.string, "[]")
        }
    }

    func testVertexUpdate() throws {
        let json = String(data: try JSONEncoder().encode(["a": "b"]), encoding: .utf8)
        let vertex = Vertex(id: 1, type: "type", data: "")
        try app.testable()
            // Create a vertex
            .test(.POST, "/vertices", json: vertex) { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqualJSON(res.body.string, vertex)
        }
            // Update data
            .test(.PATCH, "/vertices/\(vertex.id!)", json: ["data": json, "type": "new"]) { res in
                XCTAssertEqual(res.status, .ok)
                let decoded = res.vertex
                XCTAssertNotNil(decoded)
                XCTAssertEqual(decoded?.type, vertex.type, "Value shoud be equal to original")
                XCTAssertEqual(decoded?.data, json, "Data field should be replaced with the new one")
        }
            // Failed update without data
            .test(.PATCH, "/vertices/\(vertex.id!)", json: ["a": "b"]) { res in
                XCTAssertEqual(res.status, .badRequest)
        }
    }

    func testDeleteVertexWithRelationTo() throws {
        let vertexToId = 2

        try app.testable()
            .prepare {
                XCTAssertEqual(try Vertex.query(on: db).all().wait().count, 0)
                XCTAssertEqual(try Relation.query(on: db).all().wait().count, 0)

                try Vertex(id: 1, type: "t", data: "").save(on: db).wait()
                try Vertex(id: vertexToId, type: "t", data: "").save(on: db).wait()
                try Relation(id: 1, type: "t", from: 1, to: vertexToId, data: "").save(on: db).wait()
        }
            // Delete 'to' vertex
            .test(.DELETE, "/vertices/\(vertexToId)") { res in
                XCTAssertEqual(res.status, .ok)
        }
            // Verify 'to' vertex does not exist
            .test(.GET, "/vertices/\(vertexToId)") { res in
                XCTAssertEqual(res.status, .notFound)
        }
            // Verify 'from' vertex exists
            .test(.GET, "/vertices/\(1)") { res in
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
