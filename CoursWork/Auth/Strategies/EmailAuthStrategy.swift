//
//  EmailAuthStrategy.swift
//  CoursWork
//
//  Created by Admin on 28.10.2025.
//

final class EmailAuthStrategy: AuthStrategy {
    func authenticate(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        if email == "test@mail.com" && password == "1234" {
            completion(true, nil)
        } else {
            completion(false, "Невірний email або пароль.")
        }
    }
}
