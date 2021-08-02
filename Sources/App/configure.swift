import Fluent
import Vapor

func configure(app: Application, context: Context) throws {
    // Register middleware
    app.middleware.use(ErrorMiddleware.default(environment: context.environment))

    app.registerDatabase(context.databaseFactory)

    app.registerMigrations(context.databaseFactory) {
        return [
            CreateVertexModel(),
            CreateRelationModel(),
            CreateRelationCount()
        ]
    }

    try routes(app)
}
