//
//  CreateSectionFormView.swift
//  CoursWork
//
//  Created by Adrian on 17.11.2025.
//

import UIKit

final class CreateSectionFormView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    enum Difficulty: String, CaseIterable {
        case beginner = "beginner"
        case intermediate = "intermediate"
        case advanced = "advanced"
    }

    private let nameField = UITextField()
    private let difficultyField = UITextField()
    private let minAgeField = UITextField()
    private let maxAgeField = UITextField()
    private let priceField = UITextField()

    private let perksTextView = UITextView()
    private let isPremiumSwitch = UISwitch()
    private let isSubscriptionSwitch = UISwitch()
    private let submitButton = UIButton(type: .system)

    private let sportTypePicker = UIPickerView()
    private let sportTypes = ["yoga", "football", "fitness", "swimming"]
    private let sportTypeField = UITextField()

    private let difficultyPicker = UIPickerView()
    private let difficultyTypes = Difficulty.allCases.map { $0.rawValue }
    
    private let subscriptionPicker = UIPickerView()
    private let subscriptionTypes = ["week", "month", "year"]
    private let subscriptionTypeField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .systemGroupedBackground

        sportTypePicker.delegate = self
        sportTypePicker.dataSource = self
        difficultyPicker.delegate = self
        difficultyPicker.dataSource = self
        subscriptionPicker.delegate = self
        subscriptionPicker.dataSource = self

        sportTypeField.inputView = sportTypePicker
        difficultyField.inputView = difficultyPicker
        subscriptionTypeField.inputView = subscriptionPicker
        subscriptionTypeField.isHidden = true

        perksTextView.layer.borderWidth = 1
        perksTextView.layer.borderColor = UIColor.systemGray4.cgColor
        perksTextView.layer.cornerRadius = 8
        perksTextView.font = UIFont.systemFont(ofSize: 15)
        perksTextView.text = "Доступ до зали, 2 персональні тренування, Басейн раз/тиждень"
        perksTextView.textColor = .label
        perksTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        let perksLabel = UILabel()
        perksLabel.text = "Perks (comma separated)"
        perksLabel.font = .systemFont(ofSize: 16, weight: .medium)

        let stack = UIStackView(arrangedSubviews: [
            labeledField("Name", nameField),
            labeledField("Sport Type", sportTypeField),
            labeledField("Difficulty", difficultyField),
            labeledField("Min Age", minAgeField),
            labeledField("Max Age", maxAgeField),
            labeledField("Price", priceField),
            perksLabel,
            perksTextView,
            labeledSwitch("Premium", isPremiumSwitch),
            labeledSwitch("Subscription", isSubscriptionSwitch),
            labeledField("Sub. Type", subscriptionTypeField),
            submitButton
        ])

        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])

        [nameField, sportTypeField, difficultyField, minAgeField, maxAgeField, priceField, subscriptionTypeField]
            .forEach {
                $0.borderStyle = .roundedRect
                $0.heightAnchor.constraint(equalToConstant: 38).isActive = true
            }

        submitButton.setTitle("Create", for: .normal)
        submitButton.backgroundColor = .systemGreen
        submitButton.tintColor = .white
        submitButton.layer.cornerRadius = 8
        submitButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)

        isSubscriptionSwitch.addTarget(self, action: #selector(toggleSubscription), for: .valueChanged)
    }

    @objc private func toggleSubscription() {
        subscriptionTypeField.isHidden = !isSubscriptionSwitch.isOn
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == sportTypePicker { return sportTypes.count }
        if pickerView == difficultyPicker { return difficultyTypes.count }
        return subscriptionTypes.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == sportTypePicker { return sportTypes[row] }
        if pickerView == difficultyPicker { return difficultyTypes[row] }
        return subscriptionTypes[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == sportTypePicker { sportTypeField.text = sportTypes[row] }
        else if pickerView == difficultyPicker { difficultyField.text = difficultyTypes[row] }
        else { subscriptionTypeField.text = subscriptionTypes[row] }
    }

    @objc private func submitTapped() {
        guard
            let name = nameField.text, !name.isEmpty,
            let difficulty = difficultyField.text, !difficulty.isEmpty,
            let minAge = Int(minAgeField.text ?? ""),
            let maxAge = Int(maxAgeField.text ?? ""),
            let price = Double(priceField.text ?? ""),
            let userId = UserDefaults.standard.string(forKey: "id")
        else {
            showToast("Заповніть усі поля!", isError: true)
            return
        }

        let perks = perksTextView.text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

//        if isSubscriptionSwitch.isOn {
//            guard let type = subscriptionTypeField.text else {
//                showToast("Оберіть тип підписки!", isError: true)
//                return
//            }
//
//            NetworkManager.shared.createSubscriptionOffer(
//                name: name,
//                type: type,
//                price: String(price),
//                perks: perks,
//                isPremium: isPremiumSwitch.isOn
//            ) { result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success:
//                        self.showToast("Subscription created!", isError: false)
//                    case .failure:
//                        self.showToast("Помилка створення!", isError: true)
//                    }
//                }
//            }
//            return
//        }

        let sportType = sportTypeField.text ?? "fitness"

        let section: [String: Any] = [
            "name": name,
            "sportType": sportType,
            "difficulty": difficulty,
            "minAge": minAge,
            "maxAge": maxAge,
            "isPremium": isPremiumSwitch.isOn,
            "price": price,
            "createdBy": userId,
            "perks": perks
        ]

        NetworkManager.shared.createGymSection(section) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.showToast("Section created!", isError: false)
                case .failure:
                    self.showToast("Помилка створення!", isError: true)
                }
            }
        }
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

        addSubview(toast)
        toast.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            toast.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            toast.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            toast.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            toast.heightAnchor.constraint(equalToConstant: 44)
        ])

        UIView.animate(withDuration: 0.3) { toast.alpha = 1 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIView.animate(withDuration: 0.3, animations: {
                toast.alpha = 0
            }, completion: { _ in toast.removeFromSuperview() })
        }
    }

    private func labeledField(_ text: String, _ field: UITextField) -> UIStackView {
        let label = UILabel()
        label.text = text
        label.widthAnchor.constraint(equalToConstant: 110).isActive = true

        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }

    private func labeledSwitch(_ text: String, _ field: UISwitch) -> UIStackView {
        let label = UILabel()
        label.text = text
        return UIStackView(arrangedSubviews: [label, field])
    }
}
