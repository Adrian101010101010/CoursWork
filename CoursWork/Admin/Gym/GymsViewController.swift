//
//  GymsViewController.swift
//  CoursWork
//
//  Created by Adrian on 25.11.2025.
//

import UIKit

final class GymsViewController: UIViewController {

    private let tableView = UITableView()
    private var gyms: [Gym] = []
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Спортзали"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(openCreate)
        )

        setupTableView()
        setupRefresh()
        fetchGyms()
  }

@objc private func openCreate() {
    let vc = CreateSportViewController()
    vc.onCreated = { [weak self] in
        self?.fetchGyms()
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

private func fetchGyms() {
    AdminNetworkManager.shared.getAllGyms { [weak self] result in
        DispatchQueue.main.async {
            self?.refreshControl.endRefreshing()
            switch result {
            case .success(let list):
                self?.gyms = list
                self?.tableView.reloadData()
            case .failure(let error):
                print("Error fetching gyms:", error)
            }
        }
    }
}

private func setupRefresh() {
    tableView.refreshControl = refreshControl
    refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
}

@objc private func handleRefresh() {
    fetchGyms()
}

}

extension GymsViewController: UITableViewDataSource, UITableViewDelegate {

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    gyms.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let g = gyms[indexPath.row]
    cell.textLabel?.text = "\(g.id) — \(g.address)"
    return cell
}

func tableView(_ tableView: UITableView,
               commit editingStyle: UITableViewCell.EditingStyle,
               forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        let gymId = gyms[indexPath.row].id
        AdminNetworkManager.shared.deleteGym(id: gymId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.gyms.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                case .failure(let error):
                    print("Error deleting gym:", error)
                }
            }
        }
    }
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let gym = gyms[indexPath.row]
    let vc = EditGymViewController(gym: gym)
    vc.onUpdated = { [weak self] in
        self?.fetchGyms()
    }
    navigationController?.pushViewController(vc, animated: true)
}

}
