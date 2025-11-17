//
//  GymSection.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

import Foundation

struct GymSection: Codable, Identifiable {
    let id: String
    let name: String
    let sportType: SportType
    let difficulty: DifficultyLevel
    let minAge: Int
    let maxAge: Int
    let isPremium: Bool
    let createdAt: String
    let price: Double
}

enum SportType: String, Codable, CaseIterable {
    case all = "all"
    case yoga = "yoga"
    case football = "football"
    case fitness = "fitness"
    case swimming = "swimming"
}
