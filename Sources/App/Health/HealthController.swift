import Vapor

struct HealthController {
    func getHealthInfo(req: Request) throws -> EventLoopFuture<[Resource]> {
        let startTime = Date()
        let status: EventLoopFuture<Resource.Status> = VertexModel.query(on: req.db).first().flatMapAlways { result in
            switch result {
            case .success:
                return req.eventLoop.makeSucceededFuture(.available)
            case .failure:
                return req.eventLoop.makeSucceededFuture(.unavailable)
            }
        }
 
        return status.flatMap { status in
            let resource = Resource(name: "db",
                                    status: status,
                                    startTime: startTime.timeIntervalSince1970,
                                    endTime: Date().timeIntervalSince1970)
            return req.eventLoop.makeSucceededFuture([resource])
        }
    }
}
