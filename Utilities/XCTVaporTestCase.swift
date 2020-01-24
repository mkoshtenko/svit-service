import App
import XCTVapor
import Fluent
import Vapor

open class XCTVaporTestCase: XCTestCase {
    let databaseFactory: DatabaseFactory = SQLiteFactory()
    var app: Application!
    static var environment: Environment = createTestEnvironment()

    private static func createTestEnvironment() -> Environment {
        var env = Environment.testing
        try? LoggingSystem.bootstrap(from: &env)
        return env
    }

    open override func setUp() {
        super.setUp()
        app = try! App.app(context: Context(environment: XCTVaporTestCase.environment,
                                            databaseFactory: databaseFactory))

        try! app.migrator.setupIfNeeded().wait()
        try! app.migrator.prepareBatch().wait()
    }

    open override func tearDown() {
        super.tearDown()
        self.app.shutdown()
    }

    var db: Database {
        return app.databases.database(.sqlite, logger: app.logger, on: app.eventLoopGroup.next())!
    }
}

extension XCTApplicationTester {
    @discardableResult
    func prepare(closure: () throws -> ()) throws -> XCTApplicationTester {
        try closure()
        return self
    }
}
