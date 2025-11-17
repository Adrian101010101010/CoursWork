//
//  APIClient.swift
//  CoursWork
//
//  Created by Adrian on 11.11.2025.
//

import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}

    func sendRequest<T: Codable>(
        url: URL,
        method: String = "POST",
        body: [String: Any],
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -1)))
                return
            }

            if let str = String(data: data, encoding: .utf8) {
                print("Server response:", str)
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                if let userIn = decoded as? UserIn {
                    UserDefaults.standard.set(userIn.token, forKey: "idToken")
                    UserDefaults.standard.set(userIn.uid, forKey: "id")
                }
                completion(.success(decoded))
            } catch {
                print("Decoding error:", error)
                completion(.failure(error))
            }
        }.resume()
    }

}
