//
//  AuthService.swift
//  CoursWork
//
//  Created by Adrian on 11.11.2025.
//

import Foundation

final class AuthService {

    static let shared = AuthService()
    private init() {}

    func login(
        email: String,
        password: String,
        completion: @escaping (Result<UserIn, Error>) -> Void
    ) {
        guard let url = URL(string: "https://us-central1-curce-work-backend.cloudfunctions.net/loginUser") else { return }
        let body: [String: Any] = ["email": email, "password": password]

        APIClient.shared.sendRequest(url: url, body: body) { (result: Result<ResponseWrapper, Error>) in
            switch result {
            case .success(let wrapper):
                let userIn = UserIn(uid: wrapper.uid, token: wrapper.token, user: wrapper.user)
                UserDefaults.standard.set(userIn.token, forKey: "idToken")
                UserDefaults.standard.set(userIn.uid, forKey: "id")
                completion(.success(userIn))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func register(
        email: String,
        password: String,
        firstName: String,
        name: String,
        age: Int,
        height: Int,
        weight: Int,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: "https://us-central1-curce-work-backend.cloudfunctions.net/createUsers/register") else { return }

        let body: [String: Any] = [
            "email": email,
            "password": password,
            "firstName": firstName,
            "name": name,
            "age": age,
            "height": height,
            "weight": weight
        ]
        print("BODY:", body)

        APIClient.shared.sendRequest(url: url, body: body) { (result: Result<RegisterResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.uid))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
