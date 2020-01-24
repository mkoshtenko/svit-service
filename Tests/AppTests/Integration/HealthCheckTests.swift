import XCTest
import XCTVapor

@testable import App

final class HealthCheckTests: XCTVaporTestCase {
    func testStatusUp() throws {
        try app.test(.GET, "/health") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqualJSON(res.body.string, ["status": "UP"])
        }
    }

}
