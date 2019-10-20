import XCTest

@testable import App


final class RelationTests: XCTVaporTestCase {
    func testAddRelation() throws {
        let relation = Relation(id: 1, type: "t", from: 1, to: 2, data: "")
        try app.testable().start(method: .inMemory)
            .prepareDatabase() { db in
                try Vertex(id: 1, type: "t", data: "").save(on: db).wait()
                try Vertex(id: 2, type: "t", data: "").save(on: db).wait()
        }
            // Verify the are no relations
            .test(.GET, "/relations") { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqual(res.body.string, "[]")
        }
            // Add relation fails when 'from' not found
            .test(.POST, "/relations", json: Relation(type: "t", from: 100, to: 2, data: "")) { res in
                XCTAssertEqual(res.status, .notFound)
        }
            // Add relation fails when 'to' not found
            .test(.POST, "/relations", json: Relation(type: "t", from: 1, to: 200, data: "")) { res in
                XCTAssertEqual(res.status, .notFound)
        }
            // Add relation
            .test(.POST, "/relations", json: relation) { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqualJSON(res.body.string, relation)
        }
            // Verify relation was added
            .test(.GET, "/relations/\(relation.id!)") { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqualJSON(res.body.string, relation)
        }
            // Delete second vertex
            .test(.DELETE, "/relations/\(relation.id!)") { res in
                XCTAssertEqual(res.status, .ok)
        }
            // Verify relation was removed
            .test(.GET, "/relations/\(relation.id!)") { res in
                XCTAssertEqual(res.status, .notFound)
        }
            // Verify the are no relations
            .test(.GET, "/relations") { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqual(res.body.string, "[]")
        }
    }

    func testRelationUpdateData() throws {
        let json = String(data: try JSONEncoder().encode(["a": "b"]), encoding: .utf8)
        try app.testable().start(method: .inMemory)
            .prepareDatabase() { db in
                try Vertex(id: 1, type: "t", data: "").save(on: db).wait()
                try Vertex(id: 2, type: "t", data: "").save(on: db).wait()
                try Relation(id: 1, type: "t", from: 1, to: 2, data: "").save(on: db).wait()
        }
            // Update data
            .test(.PATCH, "/relations/\(1)", json: ["data": json, "type": "new"]) { res in
                XCTAssertEqual(res.status, .ok)
                let decoded = res.relation
                XCTAssertNotNil(decoded)
                XCTAssertEqual(decoded?.type, "t", "'value' shoud be equal to original")
                XCTAssertEqual(decoded?.data, json, "'data' field should be replaced with the new one")
        }
            // Update without data failed
            .test(.PATCH, "/relations/\(1)", json: ["a": "b"]) { res in
                XCTAssertEqual(res.status, .badRequest, "'data' field not found")
        }
    }
}

private extension XCTHTTPResponse {
    var relation: Relation? {
        guard let data = body.data else { return nil }
        return try? JSONDecoder().decode(Relation.self, from: data)
    }
}
