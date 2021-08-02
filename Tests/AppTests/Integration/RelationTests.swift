import XCTest
import XCTVapor
import Fluent

@testable import App

final class RelationTests: XCTVaporTestCase {
    func testGetRelationsFromVertexWithType() throws {
        try app.prepare { db in
            try VertexModel(id: 1, type: "t", data: "").save(on: db).wait()
            try RelationModel(type: "t", from: 1, to: 10, data: "").save(on: db).wait()
            try RelationModel(type: "t", from: 1, to: 20, data: "").save(on: db).wait()
            try RelationModel(type: "t1", from: 1, to: 30, data: "").save(on: db).wait()
        }.test(.GET, "/relations?from=1") { res in
            XCTAssertEqual(res.status, .badRequest)
        }.test(.GET, "/relations?from=1&type=t") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContentCountEqual(RelationModel.self, res, expected: 2)
        }.test(.GET, "/relations?from=1&type=t1") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContentCountEqual(RelationModel.self, res, expected: 1)
        }.test(.GET, "/relations?from=1&type=unknown") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContentCountEqual(RelationModel.self, res, expected: 0)
        }
    }

    func testGetRelationsFromVertexToVertexModel() throws {
        try app.prepare { db in
            try VertexModel(id: 1, type: "t", data: "").save(on: db).wait()
            try RelationModel(type: "t", from: 1, to: 10, data: "").save(on: db).wait()
            try RelationModel(type: "t1", from: 1, to:10, data: "").save(on: db).wait()
            try RelationModel(type: "t2", from: 1, to: 20, data: "").save(on: db).wait()
        }.test(.GET, "/relations?from=1") { res in
            XCTAssertEqual(res.status, .badRequest)
        }.test(.GET, "/relations?from=1&to=10") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContentCountEqual(RelationModel.self, res, expected: 2)
        }.test(.GET, "/relations?from=1&to=20") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContentCountEqual(RelationModel.self, res, expected: 1)
        }.test(.GET, "/relations?from=1&to=100") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContentCountEqual(RelationModel.self, res, expected: 0)
        }
    }

    func testGetRelationsFromVertexWithTypeToVertexNotAllowed() throws {
        try app.prepare { db in
            try VertexModel(id: 1, type: "t", data: "").save(on: db).wait()
            try RelationModel(type: "t", from: 1, to: 2, data: "").save(on: db).wait()
            try RelationModel(type: "t1", from: 1, to: 10, data: "").save(on: db).wait()
            try RelationModel(type: "t", from: 1, to: 20, data: "").save(on: db).wait()
        }.test(.GET, "/relations?from=1&type=t&to=2") { res in
            XCTAssertEqual(res.status, .badRequest, "'to' XOR 'type'")
        }
    }

    func testCreateRelationModel() throws {
        try app.prepare { db in
            try VertexModel(id: 1, type: "t", data: "").save(on: db).wait()
            try VertexModel(id: 1, type: "t", data: "").save(on: db).wait()
        }.test(.POST, "/relations", json: RelationModel(type: "a", from: 1, to: 2, data: "{}")) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, RelationModel(id: 1, type: "a", from: 1, to: 2, data: "{}"))
        }.test(.POST, "/relations", json: VertexModel(type: "", data: "")) { res in
            XCTAssertEqual(res.status, .badRequest, "Does not accept empty type")
        }
    }

    func testRelationLifecycle() throws {
        let relation = RelationModel(type: "t", from: 1, to: 2, data: "")

        try app.prepare { db in
            try VertexModel(id: 1, type: "t", data: "").save(on: db).wait()
            try VertexModel(id: 2, type: "t", data: "").save(on: db).wait()
        }.test(.POST, "/relations", json: RelationModel(type: "t", from: 100, to: 2, data: "")) { res in
            XCTAssertEqual(res.status, .notFound)
        }.test(.POST, "/relations", json: RelationModel(type: "t", from: 1, to: 200, data: "")) { res in
            XCTAssertEqual(res.status, .notFound)
        }.test(.POST, "/relations", json: relation) { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/relations/\(1)") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.DELETE, "/relations/\(1)") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/relations/\(1)") { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }

    func testDeleteRelationModel() throws {
        try app.prepare { db in
            try VertexModel(id: 1, type: "t", data: "").save(on: db).wait()
            try VertexModel(id: 2, type: "t", data: "").save(on: db).wait()
            try RelationModel(id: 1, type: "t", from: 1, to: 2, data: "").save(on: db).wait()
        }.test(.DELETE, "/relations/notId") { res in
            XCTAssertEqual(res.status, .badRequest)
        }.test(.DELETE, "/relations/\(1)") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try RelationModel.query(on: db).all().wait().count, 0, "Entity has been removed")
        }
    }

    func testRelationUpdateData() throws {
        let json = String(data: try JSONEncoder().encode(["a": "b"]), encoding: .utf8)

        try app.prepare { db in
            try VertexModel(id: 1, type: "t", data: "").save(on: db).wait()
            try VertexModel(id: 2, type: "t", data: "").save(on: db).wait()
            try RelationModel(id: 1, type: "t", from: 1, to: 2, data: "").save(on: db).wait()
        }.test(.PATCH, "/relations/notId", json: ["data": json]) { res in
            XCTAssertEqual(res.status, .badRequest)
        }.test(.PATCH, "/relations/\(1)", json: ["data": json, "type": "new"]) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContent(RelationModel.self, res) { content in
                XCTAssertEqual(content.type, "t", "'value' shoud be equal to original")
                XCTAssertEqual(content.data, json, "'data' field should be replaced with the new one")
            }
        }.test(.PATCH, "/relations/\(1)", json: ["a": "b"]) { res in
            XCTAssertEqual(res.status, .badRequest, "'data' field not found")
        }
    }

    func testAddRelationIncrementsCount() throws {
        try app.prepare { db in
            try VertexModel(id: 1, type: "", data: "").save(on: db).wait()
            try VertexModel(id: 2, type: "", data: "").save(on: db).wait()
            try VertexModel(id: 3, type: "", data: "").save(on: db).wait()
        }.test(.POST, "/relations", json: RelationModel(type: "t1", from: 1, to: 2, data: "")) { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.POST, "/relations", json: RelationModel(type: "t1", from: 1, to: 3, data: "")) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try RelationCount.query(on: db).all().wait().count, 1, "Single count entity for same relation type")
            XCTAssertEqual(try RelationCount.find(vertexId: 1, type: "t1", on: db).wait()?.value, 2)
        }.test(.POST, "/relations", json: RelationModel(type: "t2", from: 1, to: 2, data: "")) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try RelationCount.query(on: db).all().wait().count, 2, "Each relation type has own count")
            XCTAssertEqual(try RelationCount.find(vertexId: 1, type: "t2", on: db).wait()?.value, 1)
        }
    }

    func testDeleteRelationDecrementsCount() throws {
        try app.prepare { db in
            try VertexModel(id: 1, type: "", data: "").save(on: db).wait()
            try VertexModel(id: 2, type: "", data: "").save(on: db).wait()
            try VertexModel(id: 3, type: "", data: "").save(on: db).wait()
        }.test(.POST, "/relations", json: RelationModel(type: "t1", from: 1, to: 2, data: "")) { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.POST, "/relations", json: RelationModel(type: "t1", from: 1, to: 3, data: "")) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try RelationCount.query(on: db).all().wait().count, 1, "Single count entity for same relation type")
            XCTAssertEqual(try RelationCount.find(vertexId: 1, type: "t1", on: db).wait()?.value, 2)
        }.test(.DELETE, "/relations/\(1)") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try RelationCount.query(on: db).all().wait().count, 1, "Only one relation and one count")
            XCTAssertEqual(try RelationCount.find(vertexId: 1, type: "t1", on: db).wait()?.value, 1)
        }.test(.DELETE, "/relations/\(2)") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try RelationCount.query(on: db).all().wait().count, 0, "Count entity has been removed")
        }
    }
}

private func XCTAssertContentCountEqual<T>(_ type: T.Type, _ res: XCTHTTPResponse, expected: Int, file: StaticString = #file, line: UInt = #line) where T: Decodable {
    XCTAssertContent([T].self, res) { content in
        XCTAssertEqual(content.count, expected, file: file, line: line)
    }
}
