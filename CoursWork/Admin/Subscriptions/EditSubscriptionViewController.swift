//
//  EditSubscriptionViewController.swift
//  CoursWork
//
//  Created by Adrian on 25.11.2025.
//

import UIKit

final class EditSubscriptionViewController: UIViewController {

    var onUpdated: (() -> Void)?
    private var offer: SubscriptionOffer

    private let nameField = UITextField()
    private let priceField = UITextField()
    private let typeField = UITextField()
    private let perksField = UITextField()
    private let isPremiumSwitch = UISwitch()

    init(offer: SubscriptionOffer) {
        self.offer = offer
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Редагувати"

        setupUI()
        fillData()
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [
            nameField,
            priceField,
            typeField,
            perksField,
            isPremiumSwitch,
            updateButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    private lazy var updateButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Update", for: .normal)
        b.addTarget(self, action: #selector(updateTapped), for: .touchUpInside)
        return b
    }()

    private func fillData() {
        nameField.text = offer.name
        priceField.text = offer.price
        typeField.text = offer.type
        perksField.text = offer.perks.joined(separator: ", ")
        isPremiumSwitch.isOn = offer.isPremium
    }

    @objc private func updateTapped() {
        AdminNetworkManager.shared.updateSubscriptionOffer(
            id: offer.id,
            name: nameField.text ?? "",
            type: typeField.text ?? "",
            price: priceField.text ?? "",
            perks: perksField.text?.components(separatedBy: ", ") ?? [],
            isPremium: isPremiumSwitch.isOn
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.onUpdated?()
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let e):
                    print("❌ Update error:", e)
                }
            }
        }
    }
}
