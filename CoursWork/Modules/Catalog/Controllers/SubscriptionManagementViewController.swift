//
//  SubscriptionManagementViewController.swift
//  CoursWork
//
//  Created by Adrian on 04.11.2025.
//

import UIKit

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
        createSubscriptionOffer(
            name: "Тестовий абонемент",
            type: "Місячний",
            price: "200₴",
            perks: ["Доступ до залу", "2 тренування"],
            isPremium: false
        ) { result in
            switch result {
            case .success(let offer):
                print("Created offer:", offer)
            case .failure(let error):
                print("Error:", error)
            }
        }
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

    // MARK: - TableView
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
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    private let baseURL = "https://us-central1-curce-work-backend.cloudfunctions.net/subscription"

        func createSubscriptionOffer(
            name: String,
            type: String,
            price: String,
            perks: [String],
            isPremium: Bool,
            completion: @escaping (Result<SubscriptionOffer, Error>) -> Void
        ) {

            guard let url = URL(string: "\(baseURL)/subscriptions/create") else {
                completion(.failure(NSError(domain: "", code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            guard let token = UserDefaults.standard.string(forKey: "idToken") else {
                completion(.failure(NSError(domain: "", code: 401,
                    userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token"])))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let body: [String: Any] = [
                "name": name,
                "type": type,
                "price": price,
                "perks": perks,
                "isPremium": isPremium
            ]

            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "No data"])))
                    return
                }

                do {
                    let offer = try JSONDecoder().decode(SubscriptionOffer.self, from: data)
                    completion(.success(offer))
                } catch {
                    completion(.failure(error))
                }

            }.resume()
        }
}
