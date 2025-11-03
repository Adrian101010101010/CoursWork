//
//  FootballFilterStrategy.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

final class FootballFilterStrategy: FilterStrategy {
    func filter(sections: [GymSection]) -> [GymSection] {
        sections.filter { $0.sportType == .football }
    }
}
