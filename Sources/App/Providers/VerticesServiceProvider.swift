import Vapor

extension Request {
    var vertices: VerticesService {
        ServicesFactory(repositories: FluentRepository(db: db(nil)).provider)
            .makeVerticesService()
    }

    var relations: RelationsService {
        ServicesFactory(repositories: FluentRepository(db: db(nil)).provider)
            .makeRelationsService()
    }
}

private extension FluentRepository {
    var provider: ServicesFactory.RepositoryProvider {
        .init(vertices: self, relations: self)
    }
}
