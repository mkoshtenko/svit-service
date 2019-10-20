import App
import Vapor

try app(context: Context(environment: try Environment.detect(),
                         databaseFactory: PSQLFactory()))
    .run()

