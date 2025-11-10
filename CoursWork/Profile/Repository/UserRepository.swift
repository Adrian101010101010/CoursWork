//
//  UserRepository.swift
//  CoursWork
//
//  Created by Adrian on 04.11.2025.
//

import UIKit

final class UserRepository {
    static let shared = UserRepository()
    private init() {}
    
    private let defaults = UserDefaults.standard
    
    func getUserProfile() -> UserProfile {
        let cardTypeRaw = defaults.string(forKey: "cardType") ?? LoyaltyCardType.standard.rawValue
        let cardType = LoyaltyCardType(rawValue: cardTypeRaw) ?? .standard
        let points = defaults.integer(forKey: "bonusPoints")
        let name = defaults.string(forKey: "userName") ?? "Користувач"
        let email = defaults.string(forKey: "userEmail") ?? "example@email.com"
        
        return UserProfile(name: name, email: email, photo: nil, cardType: cardType, bonusPoints: points)
    }
    
    func updateBonusPoints(by amount: Int) {
        let current = defaults.integer(forKey: "bonusPoints")
        defaults.set(current + amount, forKey: "bonusPoints")
    }
    
    func updateCardType(_ type: LoyaltyCardType) {
        defaults.set(type.rawValue, forKey: "cardType")
    }
}
