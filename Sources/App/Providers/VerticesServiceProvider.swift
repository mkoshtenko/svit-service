import Vapor

extension Request {
    var vertices: VerticesService {
        ServicesFactory(repositories: FluentRepository(db: db(nil)).provider)
            .makeVerticesService()
    }
}

private extension FluentRepository {
    var provider: ServicesFactory.RepositoryProvider {
        .init(vertices: self)
    }
}
