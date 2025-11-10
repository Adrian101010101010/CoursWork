//
//  ProfileEditView.swift
//  CoursWork
//
//  Created by Adrian on 04.11.2025.
//

import UIKit

final class ProfileEditView: UIView {
    private let avatarView = UIImageView(image: UIImage(systemName: "person.circle.fill"))
    private let nameField = UITextField()
    private let emailField = UITextField()
    private let saveButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        avatarView.tintColor = .systemBlue
        avatarView.contentMode = .scaleAspectFit
        avatarView.layer.cornerRadius = 50
        avatarView.clipsToBounds = true

        nameField.placeholder = "Ваше ім’я"
        emailField.placeholder = "Email"
        [nameField, emailField].forEach {
            $0.borderStyle = .roundedRect
        }

        saveButton.setTitle("Зберегти", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 16)

        let stack = UIStackView(arrangedSubviews: [avatarView, nameField, emailField, saveButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            avatarView.heightAnchor.constraint(equalToConstant: 100),
            avatarView.widthAnchor.constraint(equalToConstant: 100),
            nameField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            emailField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            saveButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),

            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
