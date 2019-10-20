import Vapor

public protocol HasEnvironment {
    var environment: Environment { get }
}
