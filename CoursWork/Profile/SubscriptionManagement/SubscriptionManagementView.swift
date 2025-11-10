//
//  SubscriptionManagementView.swift
//  CoursWork
//
//  Created by Adrian on 04.11.2025.
//

import UIKit

final class SubscriptionManagementView: UIView {
    private let segmented = UISegmentedControl(items: ["Разовий", "Місячний", "Корпоративний"])
    private let descriptionLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private let loyaltyCardView = UIView()
    private let cardTypeLabel = UILabel()
    private let bonusLabel = UILabel()
    private let perksLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLoyaltyCard()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupUI() {
        descriptionLabel.text = "Оберіть тип абонемента для тренувань"
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        descriptionLabel.textColor = .white

        actionButton.setTitle("Оформити", for: .normal)
        actionButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        actionButton.tintColor = .white
        actionButton.backgroundColor = .systemBlue
        actionButton.layer.cornerRadius = 10
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [segmented, descriptionLabel, loyaltyCardView, actionButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            segmented.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            descriptionLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
            loyaltyCardView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
            actionButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),

            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Loyalty Card
    private func setupLoyaltyCard() {
        let user = UserRepository.shared.getUserProfile()

        loyaltyCardView.layer.cornerRadius = 16
        loyaltyCardView.layer.shadowOpacity = 0.2
        loyaltyCardView.layer.shadowRadius = 6
        loyaltyCardView.layer.shadowOffset = CGSize(width: 0, height: 2)

        switch user.cardType {
        case .standard:
            loyaltyCardView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.8)
        case .premium:
            loyaltyCardView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.3)
        case .corporate:
            loyaltyCardView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.25)
        }

        cardTypeLabel.text = "Картка: \(user.cardType.rawValue)"
        cardTypeLabel.font = .boldSystemFont(ofSize: 18)
        cardTypeLabel.textColor = .label

        bonusLabel.text = "Бонусні бали: \(user.bonusPoints)"
        bonusLabel.font = .systemFont(ofSize: 16)
        bonusLabel.textColor = .secondaryLabel

        perksLabel.text = "Переваги: \(user.cardType.perks.joined(separator: ", "))"
        perksLabel.font = .systemFont(ofSize: 14)
        perksLabel.textColor = .secondaryLabel
        perksLabel.numberOfLines = 0

        let vStack = UIStackView(arrangedSubviews: [cardTypeLabel, bonusLabel, perksLabel])
        vStack.axis = .vertical
        vStack.spacing = 6
        vStack.alignment = .leading
        loyaltyCardView.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: loyaltyCardView.topAnchor, constant: 12),
            vStack.leadingAnchor.constraint(equalTo: loyaltyCardView.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: loyaltyCardView.trailingAnchor, constant: -16),
            vStack.bottomAnchor.constraint(equalTo: loyaltyCardView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Action
    @objc private func handleAction() {
        let selected = segmented.titleForSegment(at: segmented.selectedSegmentIndex) ?? "Невідомо"
        print("Абонемент оформлено: \(selected)")

        let user = UserRepository.shared.getUserProfile()
        switch user.cardType {
        case .standard:
            UserRepository.shared.updateBonusPoints(by: 10)
        case .premium:
            UserRepository.shared.updateBonusPoints(by: 20)
        case .corporate:
            UserRepository.shared.updateBonusPoints(by: 15)
        }

        loyaltyCardView.subviews.forEach { $0.removeFromSuperview() }
        setupLoyaltyCard()
    }
}
