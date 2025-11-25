//
//  BookingsView.swift
//  CoursWork
//
//  Created by Adrian on 19.11.2025.
//

import UIKit

struct Booking: Codable {
    let id: String
    let userName: String
    let date: String
    let timeSlot: String
    let sectionId: String
    let sectionName: String?
}

final class BookingsView: UIView, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView()
    private var bookings: [Booking] = []
    private let refreshControl = UIRefreshControl()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupRefresh()
        fetchBookings()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(tableView)
        tableView.frame = bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    private func fetchBookings() {
        NetworkManager.shared.getBookingUsers { result in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()

                switch result {
                case .success(let bookings):
                    self.bookings = bookings
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error fetching bookings:", error)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        bookings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let booking = bookings[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(booking.userName) — \(booking.date) @ \(booking.timeSlot)"
        return cell
    }
    
    private func setupRefresh() {
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }

    @objc private func handleRefresh() {
        fetchBookings()
    }
}
