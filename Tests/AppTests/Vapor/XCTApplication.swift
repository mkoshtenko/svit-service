import Fluent
import Vapor

extension Application {
    func testable() throws -> XCTApplicationTester {
        try self.boot()
        return try InMemory(app: self)
    }

    private struct InMemory: XCTApplicationTester {
        let app: Application
        init(app: Application) throws {
            self.app = app
        }

        @discardableResult
        public func performTest(
            method: HTTPMethod,
            path: String,
            headers: HTTPHeaders,
            body: ByteBuffer?,
            file: StaticString,
            line: UInt,
            closure: (XCTHTTPResponse) throws -> ()
        ) throws -> XCTApplicationTester {
            let responder = self.app.make(Responder.self)
            var headers = headers
            if let body = body {
                headers.replaceOrAdd(name: .contentLength, value: body.readableBytes.description)
            }
            let path = path.hasPrefix("/") ? path : "/" + path
            let response: XCTHTTPResponse
            let request = Request(
                application: app,
                method: method,
                url: .init(string: path),
                headers: headers,
                collectedBody: body,
                remoteAddress: nil,
                on: self.app.make()
            )
            let res = try responder.respond(to: request).wait()
            response = XCTHTTPResponse(status: res.status, headers: res.headers, body: res.body)
            try closure(response)
            return self
        }
    }
}

protocol XCTApplicationTester {
    @discardableResult
    func performTest(
        method: HTTPMethod,
        path: String,
        headers: HTTPHeaders,
        body: ByteBuffer?,
        file: StaticString,
        line: UInt,
        closure: (XCTHTTPResponse) throws -> ()
    ) throws -> XCTApplicationTester
}

extension XCTApplicationTester {
    @discardableResult
    func test(
        _ method: HTTPMethod,
        _ path: String,
        headers: HTTPHeaders = [:],
        body: ByteBuffer? = nil,
        file: StaticString = #file,
        line: UInt = #line,
        closure: (XCTHTTPResponse) throws -> () = { _ in }
    ) throws -> XCTApplicationTester {
        return try self.performTest(
            method: method,
            path: path,
            headers: headers,
            body: body,
            file: file,
            line: line,
            closure: closure
        )
    }

    @discardableResult
    func test<Body>(
        _ method: HTTPMethod,
        _ path: String,
        headers: HTTPHeaders = [:],
        json: Body,
        file: StaticString = #file,
        line: UInt = #line,
        closure: (XCTHTTPResponse) throws -> () = { _ in }
    ) throws -> XCTApplicationTester
        where Body: Encodable
    {
        var body = ByteBufferAllocator().buffer(capacity: 0)
        try body.writeBytes(JSONEncoder().encode(json))
        var headers = HTTPHeaders()
        headers.contentType = .json
        return try self.test(method, path, headers: headers, body: body, closure: closure)
    }
}


extension XCTApplicationTester {
    func prepare(_ block: () throws -> Void) throws -> XCTApplicationTester {
        try block()
        return self
    }
}
