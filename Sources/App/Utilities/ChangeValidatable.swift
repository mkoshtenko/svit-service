import Vapor

protocol ChangeValidatable: Validatable {
    static func validationsForCreate(_ validations: inout Validations)
    static func validationsForUpdate(_ validations: inout Validations)
}

extension ChangeValidatable {
    static func validateCreation(_ request: Request) throws {
        try validationsForCreate().validate(request).assert()
    }

    static func validateUpdate(_ request: Request) throws {
        try validationsForUpdate().validate(request).assert()
    }

    static func validationsForCreate() -> Validations {
        var validations = Validations()
        validationsForCreate(&validations)
        return validations
    }

    static func validationsForUpdate() -> Validations {
        var validations = Validations()
        validationsForUpdate(&validations)
        return validations
    }
}
