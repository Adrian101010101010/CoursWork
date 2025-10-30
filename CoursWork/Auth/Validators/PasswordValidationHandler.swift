//
//  PasswordValidationHandler.swift
//  CoursWork
//
//  Created by Admin on 28.10.2025.
//

final class PasswordValidationHandler: ValidationHandler {
    override func validate(input: [String : String]) -> String? {
        guard let password = input["password"], password.count >= 4 else {
            return "Пароль занадто короткий"
        }
        return super.validate(input: input)
    }
}
