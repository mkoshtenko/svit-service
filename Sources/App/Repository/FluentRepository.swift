import Fluent

final class FluentRepository {
    let db: Database

    init(db: Database) {
        self.db = db
    }
}
