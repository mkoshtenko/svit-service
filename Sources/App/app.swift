import Vapor

public func app(context: Context) throws -> Application {
    var environment = context.environment
    if environment != .testing {
        try LoggingSystem.bootstrap(from: &environment)
    }

    let app = Application(environment: environment)
    try configure(app: app, context: context)

    return app
}
