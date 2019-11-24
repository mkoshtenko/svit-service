import App
import XCTest
import Fluent
import Vapor

open class XCTVaporTestCase: XCTestCase {
    var app: Application!
    let databaseFactory: DatabaseFactory = SQLiteFactory()

    open override func setUp() {
        super.setUp()
        // tries to remove test sqlite database
        try? FileManager.default.removeItem(atPath: SQLiteFactory.filePath)

        let env = Environment(name: "testing", arguments: [#file, "--auto-migrate"])
        app = try! App.app(context: Context(environment: env,
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
