//
//  SeasonTicketBooking.swift
//  CoursWork
//
//  Created by Adrian on 24.11.2025.
//

import Foundation

//struct SeasonTicketBooking: Codable {
//    let userId: String
//    let type: String
//    let createdAt: String
//}
// Модель з фейлабельним ініціалізатором
struct SeasonTicketBooking: Codable {
    let id: String
    let userId: String
    let offerId: String
    let name: String
    let type: String
    let price: String
    let perks: [String]
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, userId, offerId, name, type, price, perks, createdAt
    }
}
