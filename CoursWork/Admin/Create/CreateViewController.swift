//
//  CreateViewController.swift
//  CoursWork
//
//  Created by Adrian on 24.11.2025.
//

import UIKit


final class CreateViewController: UIViewController {

    private let firstNameField = UITextField()
    private let lastNameField = UITextField()
    private let emailField = UITextField()
    private let ageField = UITextField()
    private let heightField = UITextField()
    private let weightField = UITextField()
    private let submitButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Створити тренера"

        setupUI()
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [
            labeledField("First Name", firstNameField),
            labeledField("Last Name", lastNameField),
            labeledField("Email", emailField),
            labeledField("Age", ageField, keyboard: .numberPad),
            labeledField("Height (cm)", heightField, keyboard: .numberPad),
            labeledField("Weight (kg)", weightField, keyboard: .numberPad),
            submitButton
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        [firstNameField, lastNameField, emailField, ageField, heightField, weightField].forEach {
            $0.borderStyle = .roundedRect
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }

        submitButton.setTitle("Create Trainer", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.tintColor = .white
        submitButton.layer.cornerRadius = 8
        submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }

    private func labeledField(_ text: String, _ field: UITextField, keyboard: UIKeyboardType = .default) -> UIStackView {
        let label = UILabel()
        label.text = text
        label.widthAnchor.constraint(equalToConstant: 120).isActive = true
        field.keyboardType = keyboard
        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }

    @objc private func submitTapped() {
        guard
            let firstName = firstNameField.text, !firstName.isEmpty,
            let lastName = lastNameField.text, !lastName.isEmpty,
            let email = emailField.text, !email.isEmpty,
            let age = Int(ageField.text ?? ""),
            let height = Int(heightField.text ?? ""),
            let weight = Int(weightField.text ?? "")
        else {
            showToast("Заповніть усі поля!", isError: true)
            return
        }

        AdminNetworkManager.shared.createTrainer(
            firstName: firstName,
            name: lastName,
            email: email,
            age: age,
            height: height,
            weight: weight
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showToast("Тренера створено!", isError: false)
                    self?.clearFields()
                case .failure(let error):
                    self?.showToast("Помилка: \(error.localizedDescription)", isError: true)
                }
            }
        }
    }

    private func clearFields() {
        [firstNameField, lastNameField, emailField, ageField, heightField, weightField].forEach { $0.text = "" }
    }

    private func showToast(_ message: String, isError: Bool) {
        let toast = UILabel()
        toast.text = message
        toast.textAlignment = .center
        toast.textColor = .white
        toast.font = .systemFont(ofSize: 15, weight: .medium)
        toast.backgroundColor = isError ? UIColor.systemRed : UIColor.systemGreen
        toast.layer.cornerRadius = 10
        toast.layer.masksToBounds = true
        toast.alpha = 0

        view.addSubview(toast)
        toast.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toast.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toast.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toast.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            toast.heightAnchor.constraint(equalToConstant: 44)
        ])

        UIView.animate(withDuration: 0.3) { toast.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 0.3, animations: { toast.alpha = 0 }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
}

