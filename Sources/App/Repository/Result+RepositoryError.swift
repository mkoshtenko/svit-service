import Foundation

extension Result where Failure == RepositoryError {
    init(catching body: () throws -> Success) {
        do {
            self = .success(try body())
        } catch let error as RepositoryError {
            self = .failure(error)
        } catch {
            self = .failure(.generic(error))
        }
    }
}
