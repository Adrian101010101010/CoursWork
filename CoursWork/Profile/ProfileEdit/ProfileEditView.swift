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
    private let ageField = UITextField()
    private let weightField = UITextField()
    private let heightField = UITextField()
    private let saveButton = UIButton(type: .system)

    var onProfileSaved: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        loadLocalData()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .systemGroupedBackground

        avatarView.tintColor = .systemBlue
        avatarView.contentMode = .scaleAspectFit
        avatarView.layer.cornerRadius = 50
        avatarView.clipsToBounds = true

        nameField.placeholder = "Ваше ім’я"
        emailField.placeholder = "Email"
        ageField.placeholder = "Вік"
        weightField.placeholder = "Вага"
        heightField.placeholder = "Зріст"

        [nameField, emailField, ageField, weightField, heightField].forEach {
            $0.borderStyle = .roundedRect
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }

        ageField.keyboardType = .numberPad
        weightField.keyboardType = .numberPad
        heightField.keyboardType = .numberPad

        saveButton.setTitle("Зберегти", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        saveButton.backgroundColor = .systemBlue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 10
        saveButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            avatarView,
            nameField,
            emailField,
            ageField,
            weightField,
            heightField,
            saveButton
        ])
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
            ageField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            weightField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            heightField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            saveButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),

            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func loadLocalData() {
        let defaults = UserDefaults.standard

        nameField.text   = defaults.string(forKey: "firstName")
        emailField.text  = defaults.string(forKey: "email")

        if let age = defaults.value(forKey: "age") as? Int {
            ageField.text = "\(age)"
        }
        if let weight = defaults.value(forKey: "weight") as? Int {
            weightField.text = "\(weight)"
        }
        if let height = defaults.value(forKey: "height") as? Int {
            heightField.text = "\(height)"
        }
    }

    @objc private func saveTapped() {
        guard let userId = UserDefaults.standard.string(forKey: "id") else { return }

        let firstName = nameField.text
        let email = emailField.text
        let age = Int(ageField.text ?? "")
        let weight = Int(weightField.text ?? "")
        let height = Int(heightField.text ?? "")

        ProfileNetworkManager.shared.updateUserProfile(
            userId: userId,
            firstName: firstName,
            email: email,
            age: age,
            weight: weight,
            height: height,
            status: nil
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let defaults = UserDefaults.standard

                    defaults.set(firstName, forKey: "firstName")
                    defaults.set(email, forKey: "email")
                    defaults.set(age, forKey: "age")
                    defaults.set(weight, forKey: "weight")
                    defaults.set(height, forKey: "height")

                    self?.showToast("Профіль оновлено!", isError: false)
                    self?.onProfileSaved?()

                case .failure:
                    self?.showToast("Помилка оновлення", isError: true)
                }
            }
        }
    }

    private func showToast(_ message: String, isError: Bool) {
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.backgroundColor = isError ? .systemRed : .systemGreen
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.alpha = 0

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            label.heightAnchor.constraint(equalToConstant: 45)
        ])

        UIView.animate(withDuration: 0.3) { label.alpha = 1 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3, animations: {
                label.alpha = 0
            }, completion: { _ in label.removeFromSuperview() })
        }
    }
}
