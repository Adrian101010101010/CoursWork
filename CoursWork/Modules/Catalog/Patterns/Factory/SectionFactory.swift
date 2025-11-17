//
//  SectionFactory.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

import Foundation

final class SectionFactory {
    static func createSection(id: String, name: String, sportType: SportType, difficulty: DifficultyLevel, minAge: Int, maxAge: Int, isPremium: Bool, createdAt: String, price: Double) -> GymSection {
        return GymSection(id: id, name: name, sportType: sportType, difficulty: difficulty, minAge: minAge, maxAge: maxAge, isPremium: isPremium, createdAt: createdAt, price: price)
    }
}
