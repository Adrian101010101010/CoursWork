//
//  SectionFactory.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

import Foundation

final class SectionFactory {
    static func createSection(name: String, sportType: SportType, difficulty: DifficultyLevel, minAge: Int, maxAge: Int, isPremium: Bool) -> GymSection {
        return GymSection(id: UUID(), name: name, sportType: sportType, difficulty: difficulty, minAge: minAge, maxAge: maxAge, isPremium: isPremium)
    }
}
