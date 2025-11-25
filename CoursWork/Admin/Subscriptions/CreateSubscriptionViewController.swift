//
//  CreateSubscriptionViewController.swift
//  CoursWork
//
//  Created by Adrian on 24.11.2025.
//

import UIKit

final class CreateSubscriptionViewController: UIViewController {

    let formView = SubscriptionFormView()
    var onCreated: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Створити абонемент"
        view.backgroundColor = .systemBackground

        setupForm()
    }

    private func setupForm() {
        formView.translatesAutoresizingMaskIntoConstraints = false
        formView.onCreated = { [weak self] in
            self?.onCreated?()
            self?.navigationController?.popViewController(animated: true)
        }

        view.addSubview(formView)

        NSLayoutConstraint.activate([
            formView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            formView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            formView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
