//
//  ReservationViewModel.swift
//  CoursWork
//
//  Created by Admin on 03.11.2025.
//

import Foundation

final class ReservationViewModel {
    private let section: GymSection

    var sectionName: String { section.name }
    var sportType: String { section.sportType.rawValue }
    var difficulty: String { section.difficulty.rawValue }
    var ageRange: String { "\(section.minAge)-\(section.maxAge) років" }
    var isPremium: Bool { section.isPremium }

    init(section: GymSection) {
        self.section = section
    }
}
