//
//  SectionRepository.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

import Foundation


final class SectionRepository: SectionRepositoryProtocol {
    func fetchAllSections() -> [GymSection] {
        return [
            GymSection(id: UUID(), name: "Morning Yoga", sportType: .yoga, difficulty: .beginner, minAge: 16, maxAge: 60, isPremium: false),
            GymSection(id: UUID(), name: "Pro Football Training", sportType: .football, difficulty: .advanced, minAge: 18, maxAge: 40, isPremium: true),
            GymSection(id: UUID(), name: "Aqua Fitness", sportType: .swimming, difficulty: .intermediate, minAge: 20, maxAge: 55, isPremium: false),
            GymSection(id: UUID(), name: "CrossFit Strength", sportType: .fitness, difficulty: .advanced, minAge: 18, maxAge: 50, isPremium: true)
        ]
    }
}

