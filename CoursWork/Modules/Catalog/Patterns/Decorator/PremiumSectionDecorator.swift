//
//  PremiumSectionDecorator.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

final class PremiumSectionDecorator {
    private let section: GymSection

    init(section: GymSection) {
        self.section = section
    }

    func displayName() -> String {
        section.isPremium ? "⭐️ \(section.name)" : section.name
    }
}
