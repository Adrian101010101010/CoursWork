//
//  MySectionsView.swift
//  CoursWork
//
//  Created by Adrian on 18.11.2025.
//

import UIKit

final class MySectionsView: UIView, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView()
    private var sections: [GymSection] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("MySectionsView init called")
        setupUI()
        fetchSections()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        print("Setting up UI")
        addSubview(tableView)
        tableView.frame = bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GymSectionCell.self, forCellReuseIdentifier: GymSectionCell.identifier)
    }

    private func fetchSections() {
        guard let userId = UserDefaults.standard.string(forKey: "id") else {
            print("No userId found in UserDefaults")
            return
        }
        print("Fetching sections for userId:", userId)

        NetworkManager.shared.fetchSections { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let sections):
                    print("Fetched sections:", sections.map { $0.name })
                    self.sections = sections
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error fetching sections:", error)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection called:", sections.count)
        return sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt called for row:", indexPath.row)
        let section = sections[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: GymSectionCell.identifier, for: indexPath) as! GymSectionCell
        
        cell.nameLabel.text = section.name
        cell.priceLabel.text = "$\(section.price)"
        
        cell.editAction = {
            print("Edit tapped for", section.name)
        }
        cell.deleteAction = { [weak self, weak tableView] in
            print("Delete tapped for", section.name)
            guard let self = self, let tableView = tableView else { return }
            let id = section.id
            NetworkManager.shared.deleteSection(id: id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("Deleted section:", section.name)
                        if let currentIndex = self.sections.firstIndex(where: { $0.id == id }) {
                            self.sections.remove(at: currentIndex)
                            tableView.deleteRows(at: [IndexPath(row: currentIndex, section: 0)], with: .automatic)
                        } else {
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print("Error deleting section:", error)
                    }
                }
            }
        }
        return cell
    }
}
