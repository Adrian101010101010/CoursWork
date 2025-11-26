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
    private let baseGymURL = "https://us-central1-curce-work-backend.cloudfunctions.net/gyms"
    
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
        password: String,
        age: Int,
        height: Int,
        weight: Int,
        gym: String,
        bio: String,
        experience: String,
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
            "password": password,
            "age": age,
            "height": height,
            "weight": weight,
            "gym": gym,
            "bio": bio,
            "experience": experience
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
    
    func createGym(
        name: String,
        address: String,
        halls: [[String: Any]] = [],
        completion: @escaping (Result<[String: Any], Error>) -> Void
    ) {
        guard let url = URL(string: baseGymURL) else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        guard let token = UserDefaults.standard.string(forKey: "idToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "id": UUID().uuidString,
            "name": name,
            "address": address,
            "halls": halls
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
        completion(.failure(error))
        return
        }
        guard let data = data else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
            return
        }

        do {
            let json = try JSONSerialization.jsonObject(with: data)
            if let dict = json as? [String: Any] {
                completion(.success(dict))
            } else if let array = json as? [[String: Any]] {
                completion(.success(["response": array]))
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unexpected JSON format"])))
            }
        } catch {
            completion(.failure(error))
        }
        }.resume()
    }

    func getAllGyms(completion: @escaping (Result<[Gym], Error>) -> Void) {
        guard let url = URL(string: baseGymURL) else { return }
        guard let token = UserDefaults.standard.string(forKey: "idToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No token"])))
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
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }

            do {
                let gyms = try JSONDecoder().decode([Gym].self, from: data)
                completion(.success(gyms))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    func deleteGym(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let encodedId = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(baseGymURL)/\(encodedId)") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Gym ID"])))
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "idToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }

    func updateGym(id: String, name: String, address: String, halls: [Hall], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let encodedId = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(baseGymURL)/\(encodedId)") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Gym ID"])))
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "idToken") else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        do {
            let body = GymUpdateRequest(name: name, address: address, halls: halls)
            let bodyData = try encoder.encode(body)
            request.httpBody = bodyData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
}

