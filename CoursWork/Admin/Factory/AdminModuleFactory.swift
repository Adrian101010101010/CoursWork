//
//  AdminModuleFactory.swift
//  CoursWork
//
//  Created by Adrian on 24.11.2025.
//

import UIKit

final class AdminModuleFactory {

    func makeTrainers() -> UIViewController {
        let vc = TrainersViewController()
        vc.tabBarItem = UITabBarItem(title: "Тренери", image: UIImage(systemName: "person.3"), selectedImage: nil)
        return UINavigationController(rootViewController: vc)
    }

    func makeSubscriptions() -> UIViewController {
        let vc = SubscriptionsViewController()
        vc.tabBarItem = UITabBarItem(title: "Абонементи", image: UIImage(systemName: "doc.text"), selectedImage: nil)
        return UINavigationController(rootViewController: vc)
    }

    func makeCreate() -> UIViewController {
        let vc = CreateViewController()
        vc.tabBarItem = UITabBarItem(title: "Створити", image: UIImage(systemName: "plus.circle"), selectedImage: nil)
        return UINavigationController(rootViewController: vc)
    }
    
    func makeGyms() -> UIViewController {
        let vc = GymsViewController()
        if #available(iOS 15.0, *) {
            vc.tabBarItem = UITabBarItem(title: "Зали", image: UIImage(systemName: "dumbbell"), selectedImage: nil)
        } else {
            vc.tabBarItem = UITabBarItem(title: "Зали", image: UIImage(systemName: "sportscourt"), selectedImage: UIImage(systemName: "sportscourt.fill"))
        }
        return UINavigationController(rootViewController: vc)
    }
}
