//
//  CatalogViewController.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

import UIKit

final class CatalogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let filterView = CatalogFilterView()
    private let viewModel = CatalogViewModel(repository: SectionRepository())

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Каталог секцій"
        view.applyGradient(colors: [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor])
        setupUI()
        loadSections()
//        createGymSectionTest()
    }

    private func setupUI() {
        view.addSubview(filterView)
        view.addSubview(tableView)
        filterView.backgroundColor = .clear
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CatalogItemCell.self, forCellReuseIdentifier: CatalogItemCell.identifier)

        filterView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            filterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterView.heightAnchor.constraint(equalToConstant: 50),

            tableView.topAnchor.constraint(equalTo: filterView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        filterView.onFilterSelected = { [weak self] strategy in
                guard let self = self else { return }
                self.viewModel.applyFilter(strategy)
                print("Filtered count:", self.viewModel.getSections().count)
                self.tableView.reloadData()
            }

    }

    private func loadSections() {
        viewModel.fetchSections { [weak self] in
            self?.tableView.reloadData()
        }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getSections().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CatalogItemCell.identifier, for: indexPath) as! CatalogItemCell
        cell.configure(with: viewModel.getSections()[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("✅ Обрано секцію:", viewModel.getSections()[indexPath.row].name)
        let section = viewModel.getSections()[indexPath.row]
        let reservationVC = ReservationViewController(section: section)
        navigationController?.pushViewController(reservationVC, animated: true)
    }

    func createGymSectionTest() {
        guard let url = URL(string: "https://us-central1-curce-work-backend.cloudfunctions.net/gymSections/createGymSection") else {
            print("❌ Invalid URL")
            return
        }

        let gymSection: [String: Any] = [
            "name": "Morning Yoga",
            "sportType": "yoga",
            "difficulty": "beginner",
            "minAge": 16,
            "maxAge": 60,
            "isPremium": false
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: gymSection)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error:", error.localizedDescription)
                return
            }

            guard let data = data else {
                print("⚠️ No data received")
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("✅ Server response:", responseString)
            } else {
                print("⚠️ Could not decode server response")
            }
        }.resume()
    }
}

