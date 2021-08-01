import Foundation

enum RepositoryError: Error {
    case notFound
    case entityNotCreated
    case generic(Error)
}

typealias RepositoryCompletion<T> = (Result<T, RepositoryError>) -> Void
