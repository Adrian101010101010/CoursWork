//
//  CreateTrainerViewController.swift
//  CoursWork
//
//  Created by Adrian on 25.11.2025.
//

import UIKit

final class CreateTrainerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private let firstNameField = UITextField()
    private let lastNameField = UITextField()
    private let emailField = UITextField()
    private let passwordField = UITextField()
    private let ageField = UITextField()
    private let heightField = UITextField()
    private let weightField = UITextField()
    private let gymField = UITextField()
    private let bioField = UITextField()
    private let experienceField = UITextField()
    private let submitButton = UIButton(type: .system)

    private let gymPicker = UIPickerView()
    private var gyms: [String] = []
    private var selectedGym: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Створити тренера"

        gymPicker.delegate = self
        gymPicker.dataSource = self
        gymField.inputView = gymPicker

        setupUI()
        fetchGyms()
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [
            labeledField("First Name", firstNameField),
            labeledField("Last Name", lastNameField),
            labeledField("Email", emailField),
            labeledField("Password", passwordField),
            labeledField("Age", ageField, keyboard: .numberPad),
            labeledField("Height (cm)", heightField, keyboard: .numberPad),
            labeledField("Weight (kg)", weightField, keyboard: .numberPad),
            labeledField("Gym", gymField),
            labeledField("Bio", bioField),
            labeledField("Experience", experienceField),
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

        [firstNameField, lastNameField, emailField, passwordField, ageField, heightField, weightField, gymField, bioField, experienceField].forEach {
            $0.borderStyle = .roundedRect
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }

        passwordField.isSecureTextEntry = true 

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
        label.widthAnchor.constraint(equalToConstant: 140).isActive = true
        field.keyboardType = keyboard
        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }

    private func fetchGyms() {
        gyms = []

        if let lastAddress = UserDefaults.standard.string(forKey: "lastCreatedGymAddress") {
            gyms.append(lastAddress)
        }

        if let firstGym = gyms.first {
            selectedGym = firstGym
            gymField.text = firstGym
        }

        gymPicker.reloadAllComponents()
    }

    @objc private func submitTapped() {
        guard
            let firstName = firstNameField.text, !firstName.isEmpty,
            let lastName = lastNameField.text, !lastName.isEmpty,
            let email = emailField.text, !email.isEmpty,
            let password = passwordField.text, !password.isEmpty,
            let age = Int(ageField.text ?? ""),
            let height = Int(heightField.text ?? ""),
            let weight = Int(weightField.text ?? ""),
            let gym = selectedGym,
            let bio = bioField.text, !bio.isEmpty,
            let experience = experienceField.text, !experience.isEmpty
        else {
            showToast("Заповніть усі поля!", isError: true)
            return
        }

        AdminNetworkManager.shared.createTrainer(
            firstName: firstName,
            name: lastName,
            email: email,
            password: password,
            age: age,
            height: height,
            weight: weight,
            gym: gym,
            bio: bio,
            experience: experience
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showToast("Тренера створено!", isError: false)
                    self?.clearFields()
                case .failure(let error):
                    self?.showToast("Помилка: \(error.localizedDescription)", isError: true)
                    print(error.localizedDescription)
                }
            }
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { gyms.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { gyms[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGym = gyms[row]
        gymField.text = gyms[row]
    }

    private func clearFields() {
        [firstNameField, lastNameField, emailField, passwordField, ageField, heightField, weightField, gymField, bioField, experienceField].forEach { $0.text = "" }
        selectedGym = nil
    }

    private func showToast(_ message: String, isError: Bool) {
        let toast = UILabel()
        toast.text = message
        toast.textAlignment = .center
        toast.textColor = .white
        toast.font = .systemFont(ofSize: 15, weight: .medium)
        toast.backgroundColor = isError ? .systemRed : .systemGreen
        toast.layer.cornerRadius = 10
        toast.layer.masksToBounds = true
        toast.alpha = 0

        view.addSubview(toast)
        toast.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            toast.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            toast.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            toast.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            toast.heightAnchor.constraint(equalToConstant: 44)
        ])

        UIView.animate(withDuration: 0.3) { toast.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3, animations: { toast.alpha = 0 }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
}
