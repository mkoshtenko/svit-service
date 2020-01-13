import Vapor

protocol ChangeValidatable: Validatable {
    static func validationsForCreate(_ validations: inout Validations)
    static func validationsForUpdate(_ validations: inout Validations)
}

extension ChangeValidatable {
    static func validateCreation(_ request: Request) throws {
        var validations = self.validations()
        validationsForCreate(&validations)
        try validations.validate(request).assert()
    }

    static func validateUpdate(_ request: Request) throws {
        var validations = self.validations()
        validationsForUpdate(&validations)
        try validations.validate(request).assert()
    }
}
