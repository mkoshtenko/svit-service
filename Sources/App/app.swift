import Vapor

public func app(_ environment: Environment) throws -> Application {
    let app = Application.init(environment: environment, configure: configure)
    try boot(app)
    return app
}
