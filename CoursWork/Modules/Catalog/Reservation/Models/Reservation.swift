//
//  Reservation.swift
//  CoursWork
//
//  Created by Admin on 03.11.2025.
//

import Foundation

struct Reservation {
    let id: UUID
    let section: GymSection
    let date: Date
    let timeSlot: String
    let userName: String
}
