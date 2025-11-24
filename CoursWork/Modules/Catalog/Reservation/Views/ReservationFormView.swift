//
//  ReservationFormView.swift
//  CoursWork
//
//  Created by Admin on 03.11.2025.
//

import UIKit

final class ReservationFormView: UIView {
    var onConfirm: ((String, Date, String, Bool) -> Void)?

    private let nameField = UITextField()
    private let datePicker = UIDatePicker()
    private let timeSlotPicker = UISegmentedControl(items: ["08:00", "12:00", "16:00", "20:00"])
    private let payWithPointsSwitch = UISwitch()
    private let payWithPointsLabel = UILabel()
    private let confirmButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 3)

        nameField.placeholder = "Ваше ім’я"
        nameField.borderStyle = .roundedRect

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact

        timeSlotPicker.selectedSegmentIndex = 0
        
        payWithPointsLabel.text = "Оплатити бонусами"
        payWithPointsLabel.font = .systemFont(ofSize: 16)

        confirmButton.setTitle("Підтвердити бронювання", for: .normal)
        confirmButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        confirmButton.tintColor = .white
        confirmButton.backgroundColor = .systemBlue
        confirmButton.layer.cornerRadius = 10
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        let payStack = UIStackView(arrangedSubviews: [payWithPointsLabel, payWithPointsSwitch])
        payStack.axis = .horizontal
        payStack.spacing = 12

        let stack = UIStackView(arrangedSubviews: [
            nameField, datePicker, timeSlotPicker, payStack, confirmButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func confirmTapped() {
        guard let name = nameField.text, !name.isEmpty else { return }
        let date = datePicker.date
        let timeSlot = timeSlotPicker.titleForSegment(at: timeSlotPicker.selectedSegmentIndex) ?? ""
        onConfirm?(name, date, timeSlot, payWithPointsSwitch.isOn)
    }
}
