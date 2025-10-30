//
//  AuthStrategy.swift
//  CoursWork
//
//  Created by Admin on 28.10.2025.
//

protocol AuthStrategy {
    func authenticate(email: String, password: String, completion: @escaping (Bool, String?) -> Void)
}
