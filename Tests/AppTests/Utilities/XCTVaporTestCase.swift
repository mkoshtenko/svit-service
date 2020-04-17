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
        try! app.migrator.revertAllBatches().wait()
        self.app.shutdown()
    }

    var db: Database {
        return app.sqliteDatabase!
    }
}

extension Application {
    var sqliteDatabase: Database? {
        return databases.database(.sqlite, logger: logger, on: eventLoopGroup.next())
    }
}

extension XCTApplicationTester where Self: Application {
    @discardableResult
    func prepare(closure: (Database) throws -> ()) throws -> XCTApplicationTester {
        let database = try XCTUnwrap(sqliteDatabase)
        try closure(database)
        return self
    }
}

extension XCTApplicationTester {
    @discardableResult
    public func test<Body>(
        _ method: HTTPMethod,
        _ path: String,
        headers: HTTPHeaders = [:],
        json: Body,
        file: StaticString = #file,
        line: UInt = #line,
        beforeRequest: (inout XCTHTTPRequest) throws -> () = { _ in },
        afterResponse: (XCTHTTPResponse) throws -> () = { _ in }
    ) throws -> XCTApplicationTester
        where Body: Encodable
    {
        try test(method, path,
                 headers: headers,
                 file: file,
                 line: line,
                 beforeRequest: { req in
                    try req.content.encode(json, as: .json)
                    try beforeRequest(&req)
        },
                 afterResponse: afterResponse)
    }
}
