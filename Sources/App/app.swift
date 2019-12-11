import Vapor

public func app(context: Context) throws -> Application {
    let app = Application(context.environment)
    try configure(app: app, context: context)

    return app
}
