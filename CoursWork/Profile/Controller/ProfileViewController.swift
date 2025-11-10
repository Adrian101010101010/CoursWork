//
//  ProfileViewController.swift
//  CoursWork
//
//  Created by Adrian on 04.11.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    private let segmentedControl = UISegmentedControl(items: ["Бронювання", "Профіль", "Абонементи"])
    private let containerView = UIView()

    private let bookingHistoryView = BookingHistoryView()
    private let profileEditView = ProfileEditView()
    private let subscriptionView = SubscriptionManagementView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Мій кабінет"
        view.backgroundColor = .systemBackground
        setupUI()
        switchToView(bookingHistoryView)
    }

    private func setupUI() {
        view.addSubview(segmentedControl)
        view.addSubview(containerView)

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: switchToView(bookingHistoryView)
        case 1: switchToView(profileEditView)
        case 2: switchToView(subscriptionView)
        default: break
        }
    }

    private func switchToView(_ newView: UIView) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        containerView.addSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newView.topAnchor.constraint(equalTo: containerView.topAnchor),
            newView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            newView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
}
