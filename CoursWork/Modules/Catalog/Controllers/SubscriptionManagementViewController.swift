//
//  SubscriptionManagementViewController.swift
//  CoursWork
//
//  Created by Adrian on 04.11.2025.
//

import UIKit
import PassKit

final class SubscriptionManagementViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let viewModel = SubscriptionViewModel()
    private let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Абонементи"
        view.backgroundColor = .systemBackground
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        titleLabel.text = "Оберіть абонемент"
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center

        view.addSubview(titleLabel)
        view.addSubview(tableView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SubscriptionItemCell.self, forCellReuseIdentifier: SubscriptionItemCell.identifier)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.fetchOffers()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getOffers().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionItemCell.identifier, for: indexPath) as! SubscriptionItemCell
        cell.configure(with: viewModel.getOffers()[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offer = viewModel.getOffers()[indexPath.row]
        
        let alert = UIAlertController(
            title: "Вибрана пропозиція",
            message: "\(offer.name)\n(\(offer.type))\nЦіна: \(offer.price)\nПереваги: \(offer.perks.joined(separator: ", "))",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Купити", style: .default, handler: { [weak self] _ in
            self?.purchaseOffer(offer: offer)
        }))
        
        alert.addAction(UIAlertAction(title: "Відміна", style: .cancel))
        
        present(alert, animated: true)
    }

    private func purchaseOffer(offer: SubscriptionOffer) {
        guard let userId = UserDefaults.standard.string(forKey: "id") else {
            showAlert(title: "Помилка", message: "Не знайдено користувача")
            return
        }
        
        let priceValue = offer.price.replacingOccurrences(of: "₴", with: "").replacingOccurrences(of: "$", with: "")
        guard let priceDouble = Double(priceValue) else { return }
        let paymentAmount = NSDecimalNumber(value: priceDouble * 1)

        let request = PKPaymentRequest()
        request.merchantIdentifier = "your.merchant.id" 
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "UA"
        request.currencyCode = "UAH"

        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: offer.name, amount: paymentAmount)
        ]

        if let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) {
            paymentVC.delegate = self
            present(paymentVC, animated: true)
        } else {
            showAlert(title: "Помилка", message: "Неможливо ініціювати Apple Pay")
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func createBooking(offer: SubscriptionOffer, completion: @escaping (Bool) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "id") else {
            completion(false)
            return
        }

        let urlString = "https://us-central1-curce-work-backend.cloudfunctions.net/createSeasonTicketBooking"
        guard let url = URL(string: urlString) else { completion(false); return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "userId": userId,
            "offerId": offer.id,
            "name": offer.name,
            "type": offer.type,
            "price": offer.price,
            "perks": offer.perks
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Booking error:", error)
                    completion(false)
                    return
                }

                guard let data = data,
                      let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      responseDict["id"] != nil else {
                    completion(false)
                    return
                }

                completion(true)
            }
        }.resume()
    }

}
extension SubscriptionManagementViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        guard let selectedRow = tableView.indexPathForSelectedRow?.row else {
            completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
            return
        }
        let offer = viewModel.getOffers()[selectedRow]

        createBooking(offer: offer) { success in
            if success {
                let bonusPointsToAdd = Int((Double(offer.price.replacingOccurrences(of: "₴", with: "")) ?? 50) * 0.7)
                UserRepository.shared.updateBonusPoints(by: bonusPointsToAdd)

                completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
            } else {
                completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
            }
        }
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true)
    }
}
