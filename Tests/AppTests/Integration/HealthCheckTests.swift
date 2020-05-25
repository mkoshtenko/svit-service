import XCTest
import XCTVapor

@testable import App

final class HealthCheckTests: XCTVaporTestCase {
    func testHealthIsAvailable() throws {
        try app.test(.GET, "/health") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }

}
