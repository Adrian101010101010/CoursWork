//
//  NetworkManager.swift
//  CoursWork
//
//  Created by Adrian on 17.11.2025.
//

import UIKit

struct GymSectionTrainer: Codable {
    let id: String?
    let name: String
    let sportType: String
    let difficulty: String
    let minAge: Int
    let maxAge: Int
    let price: Double
    let perks: [String]
    let isPremium: Bool
    let createdBy: String
    let subscriptionType: String?
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    private let baseURL = "https://us-central1-curce-work-backend.cloudfunctions.net/subscription"
    private let sectionURL = "https://us-central1-curce-work-backend.cloudfunctions.net/mySection"
    
    func createGymSection(_ section: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://us-central1-curce-work-backend.cloudfunctions.net/createGymSection") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: section)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            completion(.success(responseString))
        }.resume()
    }

        func createSubscriptionOffer(
            name: String,
            type: String,
            price: String,
            perks: [String],
            isPremium: Bool,
            completion: @escaping (Result<SubscriptionOffer, Error>) -> Void
        ) {

            guard let url = URL(string: "\(baseURL)/subscriptions/create") else {
                completion(.failure(NSError(domain: "", code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            guard let token = UserDefaults.standard.string(forKey: "idToken") else {
                completion(.failure(NSError(domain: "", code: 401,
                    userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token"])))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let body: [String: Any] = [
                "name": name,
                "type": type,
                "price": price,
                "perks": perks,
                "isPremium": isPremium
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "No data"])))
                    return
                }

                do {
                    let offer = try JSONDecoder().decode(SubscriptionOffer.self, from: data)
                    completion(.success(offer))
                } catch {
                    completion(.failure(error))
                }

            }.resume()
        }
    
    private let urlString = "https://us-central1-curce-work-backend.cloudfunctions.net/getGymSections"

    func fetchSections(completion: @escaping (Result<[GymSection], Error>) -> Void) {

        guard let token = UserDefaults.standard.string(forKey: "idToken"), !token.isEmpty else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: missing token"])))
            return
        }

        guard let currentUserId = UserDefaults.standard.string(forKey: "id") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing user ID"])))
            return
        }

        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response data"])))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let bodyString = String(data: data, encoding: .utf8) ?? ""
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error: \(bodyString)"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let allSections = try decoder.decode([GymSection].self, from: data)

                // 🔥 Фільтрація за createdBy
                let filtered = allSections.filter { $0.createdBy == currentUserId }

                completion(.success(filtered))

            } catch {
                if let jsonStr = String(data: data, encoding: .utf8) {
                    print("JSON from server:", jsonStr)
                }
                completion(.failure(error))
            }

        }.resume()
    }



    
    func createOrUpdateSection(_ section: GymSectionTrainer, completion: @escaping (Result<GymSectionTrainer, Error>) -> Void) {
            guard let url = URL(string: "\(sectionURL)/sections") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                let bodyData = try JSONEncoder().encode(section)
                request.httpBody = bodyData
            } catch {
                completion(.failure(error))
                return
            }

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else { return }

                do {
                    let section = try JSONDecoder().decode(GymSectionTrainer.self, from: data)
                    completion(.success(section))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
    
    func deleteSection(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "idToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Missing token"])))
            return
        }

        // Змінено URL: передаємо ID через query ?id=...
        guard let url = URL(string: "https://us-central1-curce-work-backend.cloudfunctions.net/deleteGymSection?id=\(id)") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
                return
            }

            completion(.success(()))
        }
        .resume()
    }
}
