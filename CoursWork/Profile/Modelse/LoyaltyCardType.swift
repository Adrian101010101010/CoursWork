//
//  LoyaltyCardType.swift
//  CoursWork
//
//  Created by Adrian on 04.11.2025.
//

enum LoyaltyCardType: String, Codable {
    case standard = "Стандартна"
    case premium = "Преміум"
    case corporate = "Корпоративна"
    
    var description: String {
        switch self {
        case .standard:
            return "Базова картка для всіх користувачів."
        case .premium:
            return "Включає безкоштовний доступ до басейну та знижки на тренування."
        case .corporate:
            return "Для корпоративних клієнтів, спеціальні умови для команд."
        }
    }
    
    var perks: [String] {
        switch self {
        case .standard:
            return ["Бонуси за бронювання"]
        case .premium:
            return ["Безкоштовний басейн", "10% знижка", "Бонуси за бронювання"]
        case .corporate:
            return ["Командні знижки", "Бонуси за бронювання", "Пріоритетне бронювання"]
        }
    }
}
