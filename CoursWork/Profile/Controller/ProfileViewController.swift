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
        setupLogout()
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
