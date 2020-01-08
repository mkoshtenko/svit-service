import Vapor

protocol PublicConvertible {
    associatedtype Public: Content

    var publicContent: Public { get }
}

extension EventLoopFuture where Value: PublicConvertible {
    func convertToPublic() -> EventLoopFuture<Value.Public> {
        return map {
            $0.publicContent
        }
    }
}
