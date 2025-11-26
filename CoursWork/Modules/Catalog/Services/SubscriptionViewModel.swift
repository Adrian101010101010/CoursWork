import Foundation

final class SubscriptionViewModel {

    private(set) var offers: [SubscriptionOffer] = []

    var onUpdate: (() -> Void)?

    private let baseURL = "https://us-central1-curce-work-backend.cloudfunctions.net/subscription"

    func fetchOffers() {
        guard let url = URL(string: "\(baseURL)/subscriptions/get") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let error = error {
                print("Error loading offers:", error)
                return
            }

            guard let data = data else {
                print("Empty response")
                return
            }

            do {
                let offers = try JSONDecoder().decode([SubscriptionOffer].self, from: data)

                DispatchQueue.main.async {
                    self?.offers = offers
                    self?.onUpdate?()
                }

            } catch {
                print("JSON decode error:", error)
                print(String(data: data, encoding: .utf8) ?? "")
            }

        }.resume()
    }

    func getOffers() -> [SubscriptionOffer] {
        return offers
    }
}
