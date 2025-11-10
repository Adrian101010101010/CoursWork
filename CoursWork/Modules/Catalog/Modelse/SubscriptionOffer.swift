//
//  SubscriptionOffer.swift
//  CoursWork
//
//  Created by Adrian on 04.11.2025.
//

import Foundation

struct SubscriptionOffer {
    let id: UUID
    let name: String
    let type: String
    let price: String
    let perks: [String]
    let isPremium: Bool
}
