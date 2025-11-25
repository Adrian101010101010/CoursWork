//
//  SubscriptionsViewController.swift
//  CoursWork
//
//  Created by Adrian on 24.11.2025.
//

import UIKit

final class SubscriptionsViewController: UIViewController {

    private let tableView = UITableView()
    private var subscriptions: [SubscriptionOffer] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Абонементи"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(openCreate)
        )

        setupTableView()
        fetchSubscriptions()
    }

    @objc private func openCreate() {
        let vc = CreateSubscriptionViewController()
        vc.onCreated = { [weak self] in
            self?.fetchSubscriptions()
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self       
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchSubscriptions() {
        AdminNetworkManager.shared.getAllSubscriptions { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self.subscriptions = list
                    self.tableView.reloadData()
                case .failure(let error):
                    print("❌ Error fetching subscriptions:", error)
                }
            }
        }
    }
}


extension SubscriptionsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        subscriptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let s = subscriptions[indexPath.row]
        cell.textLabel?.text = "\(s.name) — \(s.price)₴ / \(s.type)"
        return cell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let id = subscriptions[indexPath.row].id

            AdminNetworkManager.shared.deleteSubscriptionOffer(id: id) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.subscriptions.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)

                    case .failure(let error):
                        print("Error deleting:", error)
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let offer = subscriptions[indexPath.row]

        let vc = EditSubscriptionViewController(offer: offer)
        vc.onUpdated = { [weak self] in
            self?.fetchSubscriptions()
        }

        navigationController?.pushViewController(vc, animated: true)
    }
}
