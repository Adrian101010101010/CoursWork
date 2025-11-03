//
//  FilterStrategy.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

protocol FilterStrategy {
    func filter(sections: [GymSection]) -> [GymSection]
}
