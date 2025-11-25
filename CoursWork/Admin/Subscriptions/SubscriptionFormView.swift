//
//  SubscriptionService.swift
//  CoursWork
//
//  Created by Adrian on 24.11.2025.
//

import UIKit

final class SubscriptionFormView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    private let nameField = UITextField()
    private let priceField = UITextField()
    private let perksTextView = UITextView()
    private let isPremiumSwitch = UISwitch()
    private let submitButton = UIButton(type: .system)

    private let subscriptionPicker = UIPickerView()
    private let subscriptionTypes = ["week", "month", "year"]
    private let subscriptionTypeField = UITextField()
    var onCreated: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .systemGroupedBackground

        subscriptionPicker.delegate = self
        subscriptionPicker.dataSource = self
        subscriptionTypeField.inputView = subscriptionPicker

        perksTextView.layer.borderWidth = 1
        perksTextView.layer.borderColor = UIColor.systemGray4.cgColor
        perksTextView.layer.cornerRadius = 8
        perksTextView.font = .systemFont(ofSize: 15)
        perksTextView.text = "Access to gym, personal trainer..."
        perksTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        let perksLabel = UILabel()
        perksLabel.text = "Perks (comma separated)"
        perksLabel.font = .systemFont(ofSize: 16, weight: .medium)

        let stack = UIStackView(arrangedSubviews: [
            labeledField("Name", nameField),
            labeledField("Price", priceField),
            perksLabel,
            perksTextView,
            labeledSwitch("Premium", isPremiumSwitch),
            labeledField("Type", subscriptionTypeField),
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

        [nameField, priceField, subscriptionTypeField].forEach {
            $0.borderStyle = .roundedRect
            $0.heightAnchor.constraint(equalToConstant: 38).isActive = true
        }

        submitButton.setTitle("Create Subscription", for: .normal)
        submitButton.backgroundColor = .systemGreen
        submitButton.tintColor = .white
        submitButton.layer.cornerRadius = 8
        submitButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }

    // MARK: - Picker

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        subscriptionTypes.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        subscriptionTypes[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        subscriptionTypeField.text = subscriptionTypes[row]
    }

    // MARK: - Submit Logic

    @objc private func submitTapped() {
        guard
            let name = nameField.text, !name.isEmpty,
            let price = priceField.text, !price.isEmpty,
            let type = subscriptionTypeField.text, !type.isEmpty
        else {
            showToast("Fill all fields!", isError: true)
            return
        }

        let perks = perksTextView.text
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        AdminNetworkManager.shared.createSubscriptionOffer(
            name: name,
            type: type,
            price: price,
            perks: perks,
            isPremium: isPremiumSwitch.isOn
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.showToast("Subscription created!", isError: false)
                    self.onCreated?()
                case .failure:
                    self.showToast("Error creating!", isError: true)
                }
            }
        }
    }

    // MARK: - Toast

    private func showToast(_ message: String, isError: Bool) {
        let toast = UILabel()
        toast.text = message
        toast.textAlignment = .center
        toast.textColor = .white
        toast.backgroundColor = isError ? .systemRed : .systemGreen
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

        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3, animations: { toast.alpha = 0 }) { _ in
                toast.removeFromSuperview()
            }
        }
    }

    // MARK: - Helpers

    private func labeledField(_ title: String, _ field: UITextField) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.widthAnchor.constraint(equalToConstant: 110).isActive = true

        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }

    private func labeledSwitch(_ title: String, _ field: UISwitch) -> UIStackView {
        let label = UILabel()
        label.text = title
        return UIStackView(arrangedSubviews: [label, field])
    }
}
