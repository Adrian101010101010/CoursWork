//
//  TrainersViewController.swift
//  CoursWork
//
//  Created by Adrian on 24.11.2025.
//

import UIKit



final class TrainersViewController: UIViewController {

    private let tableView = UITableView()
    private var trainers: [Trainer] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Тренери"

        setupTableView()
        loadTrainers()
        setupLogout()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TrainerCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadTrainers() {
        AdminNetworkManager.shared.fetchTrainers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let trainers):
                    self?.trainers = trainers
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Error loading trainers:", error)
                }
            }
        }
    }
    
    private func setupLogout() {
        if navigationController != nil {
            let logoutButton = UIBarButtonItem(
                image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
                style: .plain,
                target: self,
                action: #selector(logoutTapped)
            )
            navigationItem.rightBarButtonItem = logoutButton
        } else {            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right"), for: .normal)
            button.tintColor = .label
            button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                button.widthAnchor.constraint(equalToConstant: 32),
                button.heightAnchor.constraint(equalToConstant: 32)
            ])
        }
    }
    
    @objc private func logoutTapped() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "id")
        defaults.removeObject(forKey: "idToken")
        defaults.synchronize()
        
        let authVC = AuthViewController()
        let nav = UINavigationController(rootViewController: authVC)
        nav.modalPresentationStyle = .fullScreen
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }
}

extension TrainersViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trainers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trainer = trainers[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainerCell", for: indexPath)
        cell.textLabel?.text = "\(trainer.firstName) \(trainer.name) — \(trainer.email)"
        cell.detailTextLabel?.text = "Age: \(trainer.age), Height: \(trainer.height)cm, Weight: \(trainer.weight)kg"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let trainer = trainers[indexPath.row]
        print("Selected trainer:", trainer)
    }
}
