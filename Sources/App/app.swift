import Vapor

public func app(context: Context) throws -> Application {
    let app = Application(environment: context.environment) { s in
        configure(services: &s, context: context)
    }
    try boot(app)
    return app
}
