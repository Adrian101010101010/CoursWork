//
//  SectionRepository.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

import Foundation

final class SectionRepository: SectionRepositoryProtocol {

    private let urlString = "https://us-central1-curce-work-backend.cloudfunctions.net/getGymSections"

    func fetchAllSections(completion: @escaping (Result<[GymSection], Error>) -> Void) {

        guard let token = UserDefaults.standard.string(forKey: "idToken"), !token.isEmpty else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: missing token"])))
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
                let sections = try decoder.decode([GymSection].self, from: data)
                completion(.success(sections))
            } catch {
                if let jsonStr = String(data: data, encoding: .utf8) {
                    print("JSON from server:", jsonStr)
                }
                completion(.failure(error))
            }

        }.resume()
    }
}
