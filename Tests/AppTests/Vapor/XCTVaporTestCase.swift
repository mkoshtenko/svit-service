import XCTest
import Vapor
import App

public var app: (() throws -> Application) = {
    fatalError("implement static app generator")
}

open class XCTVaporTestCase: XCTestCase {
    open var app: Application!

    open override func setUp() {
        super.setUp()
        // tries to remove test sqlite database
        try? FileManager.default.removeItem(atPath: SQLiteFactory.filePath)
        
        var env = Environment.testing
        env.arguments = [#file, "--auto-migrate"]
        self.app = try! App.app(context: Context(environment: env,
                                                 databaseFactory: SQLiteFactory()))
    }

    open override func tearDown() {
        super.tearDown()
        self.app.shutdown()
    }
}
