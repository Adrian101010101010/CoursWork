//
//  CreateViewController.swift
//  CoursWork
//
//  Created by Adrian on 24.11.2025.
//

import UIKit


final class CreateViewController: UIViewController {

    private let createTrainerButton = UIButton(type: .system)
    private let createSportButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Створення"

        setupUI()
        setupActions()
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [
            createTrainerButton,
            createSportButton
        ])

        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        styleButton(createTrainerButton, title: "Створити тренера")
        styleButton(createSportButton, title: "Створити спортивну секцію")
    }

    private func styleButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    private func setupActions() {
        createTrainerButton.addTarget(self, action: #selector(openTrainerForm), for: .touchUpInside)
        createSportButton.addTarget(self, action: #selector(openSportForm), for: .touchUpInside)
    }

    @objc private func openTrainerForm() {
        let vc = CreateTrainerViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openSportForm() {
        let vc = CreateSportViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
