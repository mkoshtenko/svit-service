import App
import XCTest
import Fluent
import Vapor

open class XCTVaporTestCase: XCTestCase {
    let databaseFactory: DatabaseFactory = SQLiteFactory()
    var app: Application!
    static var environment: Environment = createTestEnvironment()

    private static func createTestEnvironment() -> Environment {
        var env = Environment(name: "testing", arguments: [#file, "--auto-migrate"])
        try? LoggingSystem.bootstrap(from: &env)
        return env
    }

    open override func setUp() {
        super.setUp()
        // tries to remove test sqlite database
        try? FileManager.default.removeItem(atPath: SQLiteFactory.filePath)

        app = try! App.app(context: Context(environment: XCTVaporTestCase.environment,
                                            databaseFactory: databaseFactory))
    }

    open override func tearDown() {
        super.tearDown()
        self.app.shutdown()
    }

    var db: Database {
        return app.databases.database(databaseFactory.databaseId)!
    }
}
