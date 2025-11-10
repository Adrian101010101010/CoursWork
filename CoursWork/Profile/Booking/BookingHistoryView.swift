//
//  BookingHistoryView.swift
//  CoursWork
//
//  Created by Adrian on 04.11.2025.
//

import UIKit

final class BookingHistoryView: UIView, UITableViewDataSource {
    private let tableView = UITableView()
    private var bookings: [String] = ["Morning Yoga — 12.10.2025", "CrossFit — 18.10.2025"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTable()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupTable() {
        addSubview(tableView)
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { bookings.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = bookings[indexPath.row]
        cell.detailTextLabel?.text = "Підтверджено ✅"
        return cell
    }
}
