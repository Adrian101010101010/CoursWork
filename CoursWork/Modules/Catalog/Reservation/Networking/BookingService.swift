//
//  BookingService.swift
//  CoursWork
//
//  Created by Adrian on 17.11.2025.
//

import Foundation

final class BookingService {

    func createBooking(
        userId: String,
        sectionId: String,
        userName: String,
        date: Date,
        timeSlot: String,
        completion: @escaping (Result<Reservation, Error>) -> Void
    ) {
        guard let url = URL(string: "https://us-central1-curce-work-backend.cloudfunctions.net/api/bookings") else { return }

        // Беремо токен із UserDefaults
        guard let idToken = UserDefaults.standard.string(forKey: "idToken") else {
            completion(.failure(NSError(domain: "NoToken", code: 401)))
            return
        }

        let dateString = ISO8601DateFormatter().string(from: date)

        let body: [String: Any] = [
            "userId": userId,
            "sectionId": sectionId,
            "userName": userName,
            "date": dateString,
            "timeSlot": timeSlot
        ]

        print("BODY:", body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let booking = try JSONDecoder().decode(Reservation.self, from: data)
                completion(.success(booking))
            } catch {
                print("JSON decode error:", String(data: data, encoding: .utf8) ?? "")
                completion(.failure(error))
            }
        }.resume()
    }
}
