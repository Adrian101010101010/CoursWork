//
//  GymSection.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

import Foundation

struct GymSection {
    let id: UUID
    let name: String
    let sportType: SportType
    let difficulty: DifficultyLevel
    let minAge: Int
    let maxAge: Int
    let isPremium: Bool
}

enum SportType: String, CaseIterable {
    case all = "Усе"
    case yoga = "Йога"
    case football = "Футбол"
    case fitness = "Фітнес"
    case swimming = "Плавання"
}
