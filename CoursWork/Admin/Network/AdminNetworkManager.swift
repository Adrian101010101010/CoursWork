//
//  AdminNetworkManager.swift
//  CoursWork
//
//  Created by Adrian on 24.11.2025.
//

import UIKit

final class AdminNetworkManager {
    static let shared = AdminNetworkManager()
    private init() {}
    private let baseURL = "https://us-central1-curce-work-backend.cloudfunctions.net/subscription"
    
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
    
    func getAllSubscriptions(completion: @escaping (Result<[SubscriptionOffer], Error>) -> Void) {

            guard let url = URL(string: "\(baseURL)/subscriptions/get") else {
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
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

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
                    let offers = try JSONDecoder().decode([SubscriptionOffer].self, from: data)
                    completion(.success(offers))
                } catch {
                    completion(.failure(error))
                }

            }.resume()
        }
    
    func updateSubscriptionOffer(
            id: String,
            name: String,
            type: String,
            price: String,
            perks: [String],
            isPremium: Bool,
            completion: @escaping (Result<Void, Error>) -> Void
        ) {
            guard let url = URL(string: "\(baseURL)/subscriptions/update") else {
                completion(.failure(NSError(domain: "", code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body: [String: Any] = [
                "id": id,
                "name": name,
                "type": type,
                "price": price,
                "perks": perks,
                "isPremium": isPremium
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }.resume()
        }

        func deleteSubscriptionOffer(
            id: String,
            completion: @escaping (Result<Void, Error>) -> Void
        ) {
            guard let url = URL(string: "\(baseURL)/subscriptions/delete") else {
                completion(.failure(NSError(domain: "", code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let body = ["id": id]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }.resume()
        }
    
    private let baseTrainerURL = "https://us-central1-curce-work-backend.cloudfunctions.net/trainer"

        func fetchTrainers(completion: @escaping (Result<[Trainer], Error>) -> Void) {

            guard let url = URL(string: "\(baseTrainerURL)/users/trainers") else {
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
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, _, error in

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
                    let trainers = try JSONDecoder().decode([Trainer].self, from: data)
                    completion(.success(trainers))
                } catch {
                    completion(.failure(error))
                }

            }.resume()
        }
    
    func createTrainer(
        firstName: String,
        name: String,
        email: String,
        age: Int,
        height: Int,
        weight: Int,
        completion: @escaping (Result<Trainer, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseTrainerURL)/users/trainers") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "firstName": firstName,
            "name": name,
            "email": email,
            "age": age,
            "height": height,
            "weight": weight
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            do {
                let trainer = try JSONDecoder().decode(Trainer.self, from: data)
                completion(.success(trainer))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}
