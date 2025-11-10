//
//  MainTabBarController.swift
//  CoursWork
//
//  Created by Adrian on 04.11.2025.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    private func setupTabs() {
        let catalogVC = UINavigationController(rootViewController: CatalogViewController())
        catalogVC.tabBarItem = UITabBarItem(title: "Каталог", image: UIImage(systemName: "list.bullet.rectangle"), tag: 0)

        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "Профіль", image: UIImage(systemName: "person.circle"), tag: 1)

        let subscriptionsVC = UINavigationController(rootViewController: SubscriptionManagementViewController())
        subscriptionsVC.tabBarItem = UITabBarItem(title: "Абонементи", image: UIImage(systemName: "creditcard"), tag: 2)

        viewControllers = [catalogVC, profileVC, subscriptionsVC]
    }

    private func setupAppearance() {
        tabBar.tintColor = .systemBlue
        tabBar.backgroundColor = .systemBackground
        tabBar.layer.cornerRadius = 20
        tabBar.layer.masksToBounds = true
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBar.layer.shadowRadius = 8
    }
}
