//
//  CreateSportViewController.swift
//  CoursWork
//
//  Created by Adrian on 25.11.2025.
//

import UIKit

final class CreateSportViewController: UIViewController {

    var onCreated: (() -> Void)?

    private let nameField = UITextField()
    private let addressField = UITextField()
    private let submitButton = UIButton(type: .system)
    private let addHallButton = UIButton(type: .system)
    private let hallsStack = UIStackView()
    
    private var halls: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Створити спортзал"

        setupUI()
    }

    private func setupUI() {
        hallsStack.axis = .vertical
        hallsStack.spacing = 8

        addHallButton.setTitle("Add Hall", for: .normal)
        addHallButton.backgroundColor = .systemGray
        addHallButton.tintColor = .white
        addHallButton.layer.cornerRadius = 8
        addHallButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addHallButton.addTarget(self, action: #selector(addHallTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            labeledField("Name", nameField),
            labeledField("Address", addressField),
            addHallButton,
            hallsStack,
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

        [nameField, addressField].forEach {
            $0.borderStyle = .roundedRect
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }

        submitButton.setTitle("Create Gym", for: .normal)
        submitButton.backgroundColor = .systemGreen
        submitButton.tintColor = .white
        submitButton.layer.cornerRadius = 8
        submitButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }

    private func labeledField(_ text: String, _ field: UITextField) -> UIStackView {
        let label = UILabel()
        label.text = text
        label.widthAnchor.constraint(equalToConstant: 140).isActive = true
        let st = UIStackView(arrangedSubviews: [label, field])
        st.axis = .horizontal
        st.spacing = 10
        return st
    }

    @objc private func addHallTapped() {
        let hallNameField = UITextField()
        hallNameField.placeholder = "Hall Name"
        hallNameField.borderStyle = .roundedRect

        let hallCapacityField = UITextField()
        hallCapacityField.placeholder = "Capacity"
        hallCapacityField.borderStyle = .roundedRect
        hallCapacityField.keyboardType = .numberPad

        let hallStack = UIStackView(arrangedSubviews: [hallNameField, hallCapacityField])
        hallStack.axis = .horizontal
        hallStack.spacing = 8
        hallStack.heightAnchor.constraint(equalToConstant: 40).isActive = true

        hallsStack.addArrangedSubview(hallStack)
    }

    @objc private func submitTapped() {
        guard let name = nameField.text, !name.isEmpty,
              let address = addressField.text, !address.isEmpty else { return }

        halls.removeAll()
        for view in hallsStack.arrangedSubviews {
            if let stack = view as? UIStackView,
               let nameField = stack.arrangedSubviews[0] as? UITextField,
               let capacityField = stack.arrangedSubviews[1] as? UITextField,
               let hallName = nameField.text, !hallName.isEmpty,
               let capacity = Int(capacityField.text ?? "") {
                halls.append(["name": hallName, "capacity": capacity])
            }
        }

        UserDefaults.standard.set(address, forKey: "lastCreatedGymAddress")

        AdminNetworkManager.shared.createGym(name: name, address: address, halls: halls) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("Gym created: \(response)")
                    self?.onCreated?()
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    print("Error creating gym: \(error)")
                }
            }
        }
    }
}
