//
//  ProfileNetworkManager.swift
//  CoursWork
//
//  Created by Adrian on 19.11.2025.
//

import Foundation

final class ProfileNetworkManager {

    static let shared = ProfileNetworkManager()
    private init() {}

    private let baseURL = "https://us-central1-curce-work-backend.cloudfunctions.net"

    func fetchUserBookings(userId: String, completion: @escaping (Result<[Booking], Error>) -> Void) {

        guard var urlComponents = URLComponents(string: "\(baseURL)/getUserBookings") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "userId", value: userId)
        ]

        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "Invalid URL components", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "Empty response", code: 0)))
                return
            }

            do {
                let bookings = try JSONDecoder().decode([Booking].self, from: data)
                completion(.success(bookings))
            } catch {
                print("Decoding error:", error)
                print("Raw JSON:", String(data: data, encoding: .utf8) ?? "nil")
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
    func updateUserProfile(
            userId: String,
            firstName: String?,
            email: String?,
            age: Int?,
            weight: Int?,
            height: Int?,
            status: String?,
            completion: @escaping (Result<UserModel, Error>) -> Void
        ) {

            guard let url = URL(string: baseURL + "/updateUserProfile") else {
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            var body: [String: Any] = ["userId": userId]

            if let firstName = firstName { body["firstName"] = firstName }
            if let email = email { body["email"] = email }
            if let age = age { body["age"] = age }
            if let weight = weight { body["weight"] = weight }
            if let height = height { body["height"] = height }
            if let status = status { body["status"] = status }

            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: 0)))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(UserResponse.self, from: data)
                    completion(.success(decoded.user))
                } catch {
                    print("Decoding error:", error)
                    completion(.failure(error))
                }

            }.resume()
        }
    
    func fetchBookings(for userId: String, completion: @escaping (Result<[SeasonTicketBooking], Error>) -> Void) {
            guard var comps = URLComponents(string: "\(baseURL)/getSeasonTicketBookings") else {
                completion(.success([]))
                return
            }
            comps.queryItems = [URLQueryItem(name: "userId", value: userId)]
            guard let url = comps.url else { completion(.success([])); return }

        let idToken = UserDefaults.standard.string(forKey: "idToken")
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        if let idToken = UserDefaults.standard.string(forKey: "idToken") {
            req.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        }


            URLSession.shared.dataTask(with: req) { data, resp, err in
                if let err = err {
                    completion(.failure(err)); return
                }
                let status = (resp as? HTTPURLResponse)?.statusCode ?? -1

                if let data = data, let raw = String(data: data, encoding: .utf8) {
                    print("🔵 fetchBookings raw response (status \(status)):\n\(raw)\n--- end raw ---")
                } else {
                    print("🔵 fetchBookings no data, status \(status)")
                }

                guard let data = data else {
                    completion(.success([])); return
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let bookings = try decoder.decode([SeasonTicketBooking].self, from: data)
                    completion(.success(bookings))
                    return
                } catch {
                    print("⚠️ JSONDecoder failed to decode [SeasonTicketBooking]:", error)
                }

                do {
                    let obj = try JSONSerialization.jsonObject(with: data, options: [])
                    if let arr = obj as? [[String: Any]] {
                        let models: [SeasonTicketBooking] = arr.compactMap { dict in
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict) else { return nil }
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .millisecondsSince1970
                            return try? decoder.decode(SeasonTicketBooking.self, from: jsonData)
                        }
                        completion(.success(models))
                    } else if let dict = obj as? [String: Any] {
                        if let innerArr = dict["bookings"] as? [[String: Any]] {
                            let models: [SeasonTicketBooking] = innerArr.compactMap { dict in
                                guard let jsonData = try? JSONSerialization.data(withJSONObject: dict) else { return nil }
                                let decoder = JSONDecoder()
                                decoder.dateDecodingStrategy = .millisecondsSince1970
                                return try? decoder.decode(SeasonTicketBooking.self, from: jsonData)
                            }
                            completion(.success(models))
                            return
                        } else if let innerArr = dict["data"] as? [[String: Any]] {
                            let models: [SeasonTicketBooking] = innerArr.compactMap { dict in
                                guard let jsonData = try? JSONSerialization.data(withJSONObject: dict) else { return nil }
                                let decoder = JSONDecoder()
                                decoder.dateDecodingStrategy = .millisecondsSince1970
                                return try? decoder.decode(SeasonTicketBooking.self, from: jsonData)
                            }
                            completion(.success(models))
                            return
                        } else if let innerArr = dict["result"] as? [[String: Any]] {
                            let models: [SeasonTicketBooking] = innerArr.compactMap { dict in
                                guard let jsonData = try? JSONSerialization.data(withJSONObject: dict) else { return nil }
                                let decoder = JSONDecoder()
                                decoder.dateDecodingStrategy = .millisecondsSince1970
                                return try? decoder.decode(SeasonTicketBooking.self, from: jsonData)
                            }
                            completion(.success(models))
                            return
                        } else {
                            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict) else {
                                completion(.success([]))
                                return
                            }
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .millisecondsSince1970
                            if let single = try? decoder.decode(SeasonTicketBooking.self, from: jsonData) {
                                completion(.success([single]))
                            } else {
                                completion(.success([]))
                            }
                            return
                        }
                    }
                    completion(.success([]))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
}

