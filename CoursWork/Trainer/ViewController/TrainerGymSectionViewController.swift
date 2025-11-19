//
//  TrainerGymSectionViewController.swift
//  CoursWork
//
//  Created by Adrian on 17.11.2025.
//

import UIKit

final class TrainerGymSectionViewController: UIViewController {
    private let filterSegmentedControl = UISegmentedControl(items: ["Create", "View", "Records"])
    private var currentStrategy: TrainerViewStrategy?
    private var contentView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupFilterControl()
        setupLogout()
        switchStrategy(to: CreateSectionStrategy())
    }
    
    private func setupFilterControl() {
        filterSegmentedControl.selectedSegmentIndex = 0
        filterSegmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterSegmentedControl)
        
        NSLayoutConstraint.activate([
            filterSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -70),
            filterSegmentedControl.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func filterChanged() {
        switch filterSegmentedControl.selectedSegmentIndex {
        case 0: switchStrategy(to: CreateSectionStrategy())
        case 1: switchStrategy(to: ViewSectionsStrategy())
        case 2: switchStrategy(to: RecordsStrategy())
        default: break
        }
    }
    
    private func switchStrategy(to strategy: TrainerViewStrategy) {
        contentView?.removeFromSuperview()
        currentStrategy = strategy
        let newView = strategy.createView()
        newView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newView)
        contentView = newView
        
        NSLayoutConstraint.activate([
            newView.topAnchor.constraint(equalTo: filterSegmentedControl.bottomAnchor, constant: 10),
            newView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
