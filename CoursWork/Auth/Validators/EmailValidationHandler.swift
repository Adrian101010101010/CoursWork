//
//  EmailValidationHandler.swift
//  CoursWork
//
//  Created by Admin on 28.10.2025.
//

final class EmailValidationHandler: ValidationHandler {
    override func validate(input: [String : String]) -> String? {
        guard let email = input["email"], email.contains("@") else {
            return "Некоректний email"
        }
        return super.validate(input: input)
    }
}
