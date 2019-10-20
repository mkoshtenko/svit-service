import Vapor

func boot(_ app: Application) throws {
    if app.environment != .testing {
        try LoggingSystem.bootstrap(from: &app.environment)
    }
    try app.boot()
}
