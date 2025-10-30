//
//  GoogleAuthStrategy.swift
//  CoursWork
//
//  Created by Admin on 28.10.2025.
//

final class GoogleAuthStrategy: AuthStrategy {
    func authenticate(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        completion(true, nil)
    }
}
