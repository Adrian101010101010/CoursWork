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
    var trainerName: String { section.trainerName }
    var gymName: String {
           section.gym?.name ?? "Без спортзалу"
       }

       var gymAddress: String {
           section.gym?.address ?? "Адреса не вказана"
       }

       var gymHalls: [String] {
           section.gym?.halls.map { "\($0.name) (\($0.capacity) місць)" } ?? []
       }

       var gymHallsDescription: String {
           let halls = section.gym?.halls ?? []
           if halls.isEmpty { return "Зали не вказані" }

           return halls
               .map { "\($0.name) (\($0.capacity))" }
               .joined(separator: ", ")
       }

       var hasGym: Bool {
           section.gym != nil
       }

    init(section: GymSection) {
        self.section = section
    }
}
