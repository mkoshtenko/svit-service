import XCTest
import XCTVapor

@testable import App


final class RelationTests: XCTVaporTestCase {
    func testAddRelation() throws {
        let relation = Relation(id: 1, type: "t", from: 1, to: 2, data: "")

        try app.prepare {
                try Vertex(id: 1, type: "t", data: "").save(on: db).wait()
                try Vertex(id: 2, type: "t", data: "").save(on: db).wait()
        }.test(.GET, "/relations") { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqual(res.body.string, "[]")
        }.test(.POST, "/relations", json: Relation(type: "t", from: 100, to: 2, data: "")) { res in
                XCTAssertEqual(res.status, .notFound)
        }.test(.POST, "/relations", json: Relation(type: "t", from: 1, to: 200, data: "")) { res in
                XCTAssertEqual(res.status, .notFound)
        }.test(.POST, "/relations", json: relation) { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqualJSON(res.body.string, relation)
        }.test(.GET, "/relations/\(relation.id!)") { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqualJSON(res.body.string, relation)
        }.test(.DELETE, "/relations/\(relation.id!)") { res in
                XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/relations/\(relation.id!)") { res in
                XCTAssertEqual(res.status, .notFound)
        }.test(.GET, "/relations") { res in
                XCTAssertEqual(res.status, .ok)
                XCTAssertEqual(res.body.string, "[]")
        }
    }

    func testRelationUpdateData() throws {
        let json = String(data: try JSONEncoder().encode(["a": "b"]), encoding: .utf8)

        try app.prepare {
                try Vertex(id: 1, type: "t", data: "").save(on: db).wait()
                try Vertex(id: 2, type: "t", data: "").save(on: db).wait()
                try Relation(id: 1, type: "t", from: 1, to: 2, data: "").save(on: db).wait()
        }.test(.PATCH, "/relations/\(1)", json: ["data": json, "type": "new"]) { res in
                XCTAssertEqual(res.status, .ok)
                let decoded = res.relation
                XCTAssertNotNil(decoded)
                XCTAssertEqual(decoded?.type, "t", "'value' shoud be equal to original")
                XCTAssertEqual(decoded?.data, json, "'data' field should be replaced with the new one")
        }.test(.PATCH, "/relations/\(1)", json: ["a": "b"]) { res in
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
