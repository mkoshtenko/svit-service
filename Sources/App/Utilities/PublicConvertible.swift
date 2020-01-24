import Vapor

protocol PublicConvertible {
    associatedtype Public: Content

    var publicContent: Public { get }
}

extension EventLoopFuture where Value: OptionalType, Value.WrappedType: PublicConvertible {
    func convertToPublic(default defaultValue: Value.WrappedType.Public) -> EventLoopFuture<Value.WrappedType.Public> {
        return map { optional in
            guard let wrapped = optional.wrapped else {
                return defaultValue;
            }
            return wrapped.publicContent
        }
    }
}
