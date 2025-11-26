//
//  Gym.swift
//  CoursWork
//
//  Created by Adrian on 25.11.2025.
//

import Foundation

struct GymUpdateRequest: Codable {
    let name: String
    let address: String
    let halls: [Hall]
}

struct Gym: Codable {
    let id: String
    let name: String
    let address: String
    let halls: [Hall]
}

struct Hall: Codable {
    let name: String
    let capacity: Int
}

