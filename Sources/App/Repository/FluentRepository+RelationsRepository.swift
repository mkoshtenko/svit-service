import Fluent

extension FluentRepository: RelationsRepository {
    func findRelations(using query: RelationsQuery, completion: @escaping RepositoryCompletion<[Relation]>) {
        query.builder(db).all()
            .whenComplete { result in
                completion(Result(catching: { try result.getVertices() }))
            }
    }

    func deleteRelations(ids: [RelationID], completion: @escaping RepositoryCompletion<[RelationID]>) {
        RelationModel.query(on: db)
            .filter(\.$id ~~ ids)
            .delete()
            .whenComplete { result in
                completion(
                    Result(catching: {
                        try result.get()
                        return ids
                    })
                )
            }
    }
}

private extension Result where Success == RelationModel {
    func getVertex() throws -> Relation {
        switch self {
        case .success(let value):
            return try value.relation()
        case .failure(let error):
            throw error
        }
    }
}

private extension Result where Success == Array<RelationModel> {
    func getVertices() throws -> [Relation] {
        switch self {
        case .success(let value):
            return value.compactMap { try? $0.relation() }
        case .failure(let error):
            throw error
        }
    }
}

private extension RelationModel {
    func relation() throws -> Relation {
        guard let relationID = id else { throw RepositoryError.entityNotCreated }
        return Relation(id: relationID, type: type, from: from, to: to, data: data)
    }
}

private extension RelationsQuery {
    func builder(_ db: Database) -> QueryBuilder<RelationModel> {
        let builder = RelationModel.query(on: db)

        switch self {
        case .relatedToVertex(let id):
            builder.group(.or) { group in
                group.filter(\.$from == id).filter(\.$to == id)
            }
        }

        return builder
    }
}
