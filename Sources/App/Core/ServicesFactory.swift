import Foundation

final class ServicesFactory {
    struct RepositoryProvider {
        let vertices: VerticesRepository
        let relations: RelationsRepository
    }

    private let repositories: RepositoryProvider
    private var relationsService: RelationsServiceImpl?

    init(repositories: RepositoryProvider) {
        self.repositories = repositories
    }

    func makeVerticesService() -> VerticesService {
        let relationsService = reusedRelationsService()
        return VerticesServiceImpl(
            repository: repositories.vertices,
            delegate: relationsService
        )
    }

    func makeRelationsService() -> RelationsService {
        reusedRelationsService()
    }

    private func reusedRelationsService() -> RelationsServiceImpl {
        let service = relationsService ?? RelationsServiceImpl(repository: repositories.relations)
        relationsService = service
        return service
    }
}
