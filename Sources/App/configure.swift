import Fluent
import Vapor

func configure(app: Application, context: Context) throws {
    // Register providers first
    app.provider(FluentProvider())

    // Register middleware
    app.register(extension: MiddlewareConfiguration.self) { middlewares, app in
        middlewares.use(app.make(ErrorMiddleware.self))
    }

    app.registerDatabase(context.databaseFactory)

    app.registerMigrations(context.databaseFactory) {
        return [CreateVertex(),
                CreateRelation()]
    }

    try routes(app)
}
