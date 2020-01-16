import XCTest
import XCTVapor

@testable import App


final class RelationTests: XCTVaporTestCase {

    func testRelationLifecycle() throws {
        let relation = Relation(type: "t", from: 1, to: 2, data: "")

        try app.prepare {
            try Vertex(id: 1, type: "t", data: "").save(on: db).wait()
            try Vertex(id: 2, type: "t", data: "").save(on: db).wait()
        }.test(.POST, "/relations", json: Relation(type: "t", from: 100, to: 2, data: "")) { res in
            XCTAssertEqual(res.status, .notFound)
        }.test(.POST, "/relations", json: Relation(type: "t", from: 1, to: 200, data: "")) { res in
            XCTAssertEqual(res.status, .notFound)
        }.test(.POST, "/relations", json: relation) { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/relations/\(1)") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.DELETE, "/relations/\(1)") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/relations/\(1)") { res in
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

    func testAddRelationIncrementsCount() throws {
        try app.prepare {
            try Vertex(id: 1, type: "", data: "").save(on: db).wait()
            try Vertex(id: 2, type: "", data: "").save(on: db).wait()
            try Vertex(id: 3, type: "", data: "").save(on: db).wait()
        }.test(.POST, "/relations", json: Relation(type: "t1", from: 1, to: 2, data: "")) { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.POST, "/relations", json: Relation(type: "t1", from: 1, to: 3, data: "")) { res in
            XCTAssertEqual(res.status, .ok)
        }.prepare {
            XCTAssertEqual(try RelationCount.query(on: db).all().wait().count, 1, "Single count entity for same relation type")
            XCTAssertEqual(try RelationCount.find(vertexId: 1, type: "t1", on: db).wait()?.value, 2)
        }.test(.POST, "/relations", json: Relation(type: "t2", from: 1, to: 2, data: "")) { res in
            XCTAssertEqual(res.status, .ok)
        }.prepare {
            XCTAssertEqual(try RelationCount.query(on: db).all().wait().count, 2, "Each relation type has own count")
            XCTAssertEqual(try RelationCount.find(vertexId: 1, type: "t2", on: db).wait()?.value, 1)
        }
    }

    func testDeleteRelationDecrementsCount() throws {
        try app.prepare {
            try Vertex(id: 1, type: "", data: "").save(on: db).wait()
            try Vertex(id: 2, type: "", data: "").save(on: db).wait()
            try Vertex(id: 3, type: "", data: "").save(on: db).wait()
        }.test(.POST, "/relations", json: Relation(type: "t1", from: 1, to: 2, data: "")) { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.POST, "/relations", json: Relation(type: "t1", from: 1, to: 3, data: "")) { res in
            XCTAssertEqual(res.status, .ok)
        }.prepare {
            XCTAssertEqual(try RelationCount.query(on: db).all().wait().count, 1, "Single count entity for same relation type")
            XCTAssertEqual(try RelationCount.find(vertexId: 1, type: "t1", on: db).wait()?.value, 2)
        }.test(.DELETE, "/relations/\(1)") { res in
            XCTAssertEqual(res.status, .ok)
        }.prepare {
            XCTAssertEqual(try RelationCount.query(on: db).all().wait().count, 1, "Only one relation and one count")
            XCTAssertEqual(try RelationCount.find(vertexId: 1, type: "t1", on: db).wait()?.value, 1)
        }.test(.DELETE, "/relations/\(2)") { res in
            XCTAssertEqual(res.status, .ok)
        }.prepare {
            XCTAssertEqual(try RelationCount.query(on: db).all().wait().count, 0, "Count entity has been removed")
        }
    }
}

private extension XCTHTTPResponse {
    var relation: Relation? {
        guard let data = body.data else { return nil }
        return try? JSONDecoder().decode(Relation.self, from: data)
    }
}
