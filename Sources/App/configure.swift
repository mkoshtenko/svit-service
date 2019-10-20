import Fluent
import Vapor

/// Called before your application initializes.
func configure(services s: inout Services, context: Context) {
    /// Register providers first
    s.provider(FluentProvider())

    /// Register routes
    s.extend(Routes.self) { r, c in
        try routes(r, c)
    }

    /// Register middleware
    s.register(MiddlewareConfiguration.self) { c in
        // Create _empty_ middleware config
        var middlewares = MiddlewareConfiguration()
        
        // Serves files from `Public/` directory
        /// middlewares.use(FileMiddleware.self)
        
        // Catches errors and converts to HTTP response
        try middlewares.use(c.make(ErrorMiddleware.self))
        
        return middlewares
    }

    s.registerDatabase(context.databaseFactory)

    s.registerMigrations(context.databaseFactory) {
        return [CreateVertex(),
                CreateRelation()]
    }
}
