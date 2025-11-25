//
//  BookingHistoryView.swift
//  CoursWork
//
//  Created by Adrian on 04.11.2025.
//

import UIKit

final class BookingHistoryView: UIView, UITableViewDataSource, UITableViewDelegate {

    private let tableView = UITableView()
    private let activity = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()

    private var bookings: [Booking] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTable()
        setupLoader()
        loadBookings()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupTable() {
        addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        refreshControl.tintColor = .systemBlue
        refreshControl.addTarget(self, action: #selector(refreshTriggered), for: .valueChanged)
        tableView.refreshControl = refreshControl


        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupLoader() {
        addSubview(activity)
        activity.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activity.centerXAnchor.constraint(equalTo: centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func loadBookings() {
        guard let userId = UserDefaults.standard.string(forKey: "id") else { return }
        activity.startAnimating()

        ProfileNetworkManager.shared.fetchUserBookings(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.activity.stopAnimating()

                switch result {
                case .success(let data):
                    self?.bookings = data
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Fetch error:", error)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let booking = bookings[indexPath.row]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = booking.sectionName ?? "Секція: \(booking.sectionId)"
        cell.detailTextLabel?.text = "\(booking.date) • \(booking.timeSlot)"
        return cell
    }
    
    @objc private func refreshTriggered() {
        loadBookings()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshControl.endRefreshing()
        }
    }
}
