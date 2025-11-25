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
    private let refreshControl = UIRefreshControl()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("MySectionsView init called")
        setupUI()
        setupRefresh()
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
            DispatchQueue.main.async { [weak self] in
                self!.tableView.reloadData()
                self!.refreshControl.endRefreshing()

                guard let self = self else { return }
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
        
        cell.editAction = { [weak self] in
            guard let self = self,
                  let parentVC = self.parentViewController else { return }

            let vc = EditSectionViewController(section: section)

            vc.onSave = { updatedSection in
                let id = updatedSection.id

                let updates: [String: Any] = [
                    "name": updatedSection.name,
                    "price": updatedSection.price,
                    "difficulty": updatedSection.difficulty.rawValue,
                    "sportType": updatedSection.sportType.rawValue,
                    "minAge": updatedSection.minAge,
                    "maxAge": updatedSection.maxAge,
                    "isPremium": updatedSection.isPremium
                ]

                NetworkManager.shared.editSection(id: id, updates: updates) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            if let index = self.sections.firstIndex(where: { $0.id == id }) {
                                self.sections[index] = updatedSection
                                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            }
                        case .failure(let error):
                            print("Error editing:", error)
                        }
                    }
                }
            }
            print("parentVC =", self.parentViewController as Any)
            print("nav =", parentVC.navigationController as Any)

            parentVC.present(vc, animated: true)
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
    
    private func setupRefresh() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    @objc private func handleRefresh() {
        fetchSections()
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let next = parentResponder?.next {
            parentResponder = next
            if let vc = parentResponder as? UIViewController {
                return vc
            }
        }
        return nil
    }
}
