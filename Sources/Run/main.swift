import App
import Vapor

private func environment() throws -> Environment {
    var env = try Environment.detect()
    try LoggingSystem.bootstrap(from: &env)
    return env
}

try app(context: Context(environment: environment(),
                         databaseFactory: PSQLFactory()))
    .run()
