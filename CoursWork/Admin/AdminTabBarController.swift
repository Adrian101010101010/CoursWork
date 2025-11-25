//
//  AdminTabBarController.swift
//  CoursWork
//
//  Created by Adrian on 24.11.2025.
//

import UIKit

final class AdminTabBarController: UITabBarController {

    private let factory = AdminModuleFactory()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [
            factory.makeTrainers(),
            factory.makeSubscriptions(),
            factory.makeCreate()
        ]

        tabBar.backgroundColor = .systemBackground
    }
}
