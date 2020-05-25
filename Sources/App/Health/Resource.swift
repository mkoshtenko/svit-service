import Vapor

struct Resource: Content {
    enum Status: String, Codable {
        // all good with the resource
        case available
        // resource is unavailable
        case unavailable
    }

    let name: String
    let status: Status
    let startTime: TimeInterval
    let endTime: TimeInterval
}
