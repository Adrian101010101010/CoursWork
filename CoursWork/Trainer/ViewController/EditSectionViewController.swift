//
//  EditSectionViewController.swift
//  CoursWork
//
//  Created by Adrian on 19.11.2025.
//

import UIKit

final class EditSectionViewController: UIViewController {

    var section: GymSection
    var onSave: ((GymSection) -> Void)?

    private let nameField = UITextField()
    private let priceField = UITextField()
    private let minAgeField = UITextField()
    private let maxAgeField = UITextField()
    private let difficultyField = UITextField()
    private let sportTypeField = UITextField()
    private let isPremiumSwitch = UISwitch()

    init(section: GymSection) {
        self.section = section
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupUI()
        fillData()
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [
            createField(nameField, placeholder: "Name"),
            createField(priceField, placeholder: "Price", keyboard: .decimalPad),
            createField(minAgeField, placeholder: "Min Age", keyboard: .numberPad),
            createField(maxAgeField, placeholder: "Max Age", keyboard: .numberPad),
            createField(difficultyField, placeholder: "Difficulty"),
            createField(sportTypeField, placeholder: "Sport Type"),
            isPremiumSwitch
        ])
        
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)

        let topBar = UIView()
            topBar.backgroundColor = .systemGray6
            topBar.translatesAutoresizingMaskIntoConstraints = false
            
            let saveButton = UIButton(type: .system)
            saveButton.setTitle("Save", for: .normal)
            saveButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
            saveButton.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
            saveButton.translatesAutoresizingMaskIntoConstraints = false
            
            topBar.addSubview(saveButton)
            view.addSubview(topBar)
            
            NSLayoutConstraint.activate([
                topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                topBar.heightAnchor.constraint(equalToConstant: 56),
                
                saveButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
                saveButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
                
                stack.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 20),
                stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ])

    }

    private func fillData() {
        nameField.text = section.name
        priceField.text = "\(section.price)"
        minAgeField.text = "\(section.minAge)"
        maxAgeField.text = "\(section.maxAge)"
        difficultyField.text = section.difficulty.rawValue
        sportTypeField.text = section.sportType.rawValue
        isPremiumSwitch.isOn = section.isPremium
    }

    private func createField(_ field: UITextField, placeholder: String, keyboard: UIKeyboardType = .default) -> UITextField {
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.keyboardType = keyboard
        return field
    }

    @objc private func savePressed() {
        guard let price = Double(priceField.text ?? ""),
              let minAge = Int(minAgeField.text ?? ""),
              let maxAge = Int(maxAgeField.text ?? "") else {
            return
        }

        section = GymSection(
            id: section.id,
            name: nameField.text ?? section.name,
            sportType: SportType(rawValue: sportTypeField.text ?? section.sportType.rawValue) ?? section.sportType,
            difficulty: DifficultyLevel(rawValue: difficultyField.text ?? section.difficulty.rawValue) ?? section.difficulty,
            minAge: minAge,
            maxAge: maxAge,
            isPremium: isPremiumSwitch.isOn,
            createdAt: section.createdAt,
            price: price,
            createdBy: section.createdBy
        )

        onSave?(section)
        navigationController?.popViewController(animated: true)
    }
}
