//
//  EditGymViewController.swift
//  CoursWork
//
//  Created by Adrian on 25.11.2025.
//

import UIKit

final class EditGymViewController: UIViewController {

    private let gym: Gym
    var onUpdated: (() -> Void)?

    private let nameField = UITextField()
    private let addressField = UITextField()
    private let saveButton = UIButton(type: .system)
    private let addHallButton = UIButton(type: .system)
    private let hallsStack = UIStackView()
    
    private var halls: [Hall] = []

    init(gym: Gym) {
        self.gym = gym
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Редагувати спортзал"

        setupUI()
        populateFields()
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
            saveButton
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

        saveButton.setTitle("Зберегти", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 8
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }

    private func labeledField(_ text: String, _ field: UITextField) -> UIStackView {
        let label = UILabel()
        label.text = text
        label.widthAnchor.constraint(equalToConstant: 140).isActive = true
        let stack = UIStackView(arrangedSubviews: [label, field])
        stack.axis = .horizontal
        stack.spacing = 10
        return stack
    }

    private func populateFields() {
        nameField.text = gym.name
        addressField.text = gym.address
        
        halls = gym.halls
        for hall in halls {
            addHallView(name: hall.name, capacity: hall.capacity)
        }
    }

    @objc private func addHallTapped() {
        addHallView(name: "", capacity: 0)
    }

    private func addHallView(name: String, capacity: Int) {
        let hallNameField = UITextField()
        hallNameField.placeholder = "Hall Name"
        hallNameField.text = name
        hallNameField.borderStyle = .roundedRect

        let hallCapacityField = UITextField()
        hallCapacityField.placeholder = "Capacity"
        hallCapacityField.text = capacity > 0 ? "\(capacity)" : ""
        hallCapacityField.borderStyle = .roundedRect
        hallCapacityField.keyboardType = .numberPad

        let removeButton = UIButton(type: .system)
        removeButton.setTitle("X", for: .normal)
        removeButton.setTitleColor(.red, for: .normal)
        removeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true

        let hallStack = UIStackView(arrangedSubviews: [hallNameField, hallCapacityField, removeButton])
        hallStack.axis = .horizontal
        hallStack.spacing = 8
        hallStack.heightAnchor.constraint(equalToConstant: 40).isActive = true

        removeButton.addAction(UIAction { [weak self, weak hallStack] _ in
            guard let self, let hallStack = hallStack else { return }
            self.hallsStack.removeArrangedSubview(hallStack)
            hallStack.removeFromSuperview()
        }, for: .touchUpInside)

        hallsStack.addArrangedSubview(hallStack)
    }

    @objc private func saveTapped() {
        guard
            let name = nameField.text, !name.isEmpty,
            let address = addressField.text, !address.isEmpty
        else {
            showToast("Заповніть усі поля!", isError: true)
            return
        }

        var newHalls: [Hall] = []
        for view in hallsStack.arrangedSubviews {
            if let stack = view as? UIStackView,
               let nameField = stack.arrangedSubviews[0] as? UITextField,
               let capacityField = stack.arrangedSubviews[1] as? UITextField,
               let hallName = nameField.text, !hallName.isEmpty,
               let capacity = Int(capacityField.text ?? "") {
                newHalls.append(Hall(name: hallName, capacity: capacity))
            }
        }

        AdminNetworkManager.shared.updateGym(
            id: gym.id,
            name: name,
            address: address,
            halls: newHalls
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showToast("Змінено успішно!", isError: false)
                    self?.onUpdated?()
                    self?.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self?.showToast("Помилка: \(error.localizedDescription)", isError: true)
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
        toast.backgroundColor = isError ? .systemRed : .systemGreen
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3, animations: { toast.alpha = 0 }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
}
