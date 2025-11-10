import Foundation

final class SubscriptionViewModel {
    private(set) var offers: [SubscriptionOffer] = [
        SubscriptionOffer(id: UUID(), name: "Разовий абонемент", type: "Разовий", price: "150₴", perks: ["Доступ на 1 тренування"], isPremium: false),
        SubscriptionOffer(id: UUID(), name: "Місячний абонемент", type: "Місячний", price: "450₴", perks: ["Безліміт на місяць", "1 гість"], isPremium: false),
        SubscriptionOffer(id: UUID(), name: "Преміум абонемент", type: "Місячний", price: "950₴", perks: ["VIP-зона", "Групові заняття", "2 гостя"], isPremium: true),
        SubscriptionOffer(id: UUID(), name: "Корпоративний пакет", type: "Корпоративний", price: "3500₴", perks: ["10 осіб", "VIP-зони", "Індивідуальні тренери"], isPremium: true)
    ]
    var onUpdate: (() -> Void)?
    
    func getOffers() -> [SubscriptionOffer] {
        offers
    }
}
