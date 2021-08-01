import XCTest
import XCTVapor

@testable import App

final class RelationCountTests: XCTVaporTestCase {
    func testRelationsCountReturnsNotFound() throws {
        try app.prepare { db in
            try VertexModel(id: 1, type: "t", data: "").save(on: db).wait()
        }.test(.GET, "/count?from=1&type=a") { res in
            XCTAssertEqual(res.status, .ok)
        }.test(.GET, "/count?from=10&type=a") { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }

    func testRelationsCountReturnsObject() throws {
        try app.prepare { db in
            try VertexModel(id: 1, type: "t", data: "").save(on: db).wait()
            try RelationCount(id: 100, type: "t1", from: 1, value: 123).save(on: db).wait()
        }.test(.GET, "/count?from=1&type=t1") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContent(RelationCount.Public.self, res) { content in
                XCTAssertEqual(content, RelationCount.Public(from: 1, type: "t1", count: 123))
            }
        }.test(.GET, "/count?from=1&type=t2") { res in
            XCTAssertContent(RelationCount.Public.self, res) { content in
                XCTAssertEqual(content, RelationCount.Public(from: 1, type: "t2", count: 0))
            }
        }
    }
}
