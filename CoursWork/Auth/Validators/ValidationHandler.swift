//
//  ValidationHandler.swift
//  CoursWork
//
//  Created by Admin on 28.10.2025.
//

class ValidationHandler {
    private var next: ValidationHandler?

    func setNext(_ handler: ValidationHandler) -> ValidationHandler {
        next = handler
        return handler
    }

    func validate(input: [String: String]) -> String? {
        return next?.validate(input: input)
    }
}
