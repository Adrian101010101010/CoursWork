//
//  Reservation.swift
//  CoursWork
//
//  Created by Admin on 03.11.2025.
//

import Foundation

struct Reservation: Codable {
    let sectionId: String
    let userName: String
    let date: String
    let timeSlot: String
    let createdAt: String
}
