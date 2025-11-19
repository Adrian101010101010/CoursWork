//
//  AuthViewController.swift
//  CoursWork
//
//  Created by Admin on 28.10.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    private let logoImageView = UIImageView()
    private let emailField = AuthTextField(placeholder: "Email")
    private let passwordField = AuthTextField(placeholder: "Пароль", isSecure: true)
    private let firstNameField = AuthTextField(placeholder: "Ім’я")
    private let lastNameField = AuthTextField(placeholder: "Прізвище")
    private let ageField = AuthTextField(placeholder: "Вік")
    private let heightField = AuthTextField(placeholder: "Зріст (см)")
    private let weightField = AuthTextField(placeholder: "Вага (кг)")
    
    private let actionButton = UIButton(type: .system)
    private let switchModeButton = UIButton(type: .system)
    
    private var isLoginMode = true
    private var authStrategy: AuthStrategy = EmailAuthStrategy()
    private var validationChain: ValidationHandler?
    
    private let agePicker = UIPickerView()
    private let heightPicker = UIPickerView()
    private let weightPicker = UIPickerView()
    
    private var activePickerField: UITextField?
    private var stack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupValidationChain()
        setupKeyboardHandling()
        setupPickers()
    }
    
    private func setupUI() {
        view.applyGradient(colors: [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor])
        
        logoImageView.image = UIImage(named: "Logo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.alpha = 0
        
        emailField.delegate = self
        passwordField.delegate = self
        
        [firstNameField, lastNameField, ageField, heightField, weightField].forEach {
            $0.isHidden = true
            $0.delegate = self
        }
        
        ageField.inputView = agePicker
        heightField.inputView = heightPicker
        weightField.inputView = weightPicker
        
        actionButton.setTitle("Увійти", for: .normal)
        actionButton.tintColor = .clear
        actionButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        actionButton.configuration = .prominentGlass()
        actionButton.layer.cornerRadius = 12
        actionButton.addTarget(self, action: #selector(handleAuth), for: .touchUpInside)
        
        switchModeButton.setTitle("Немає акаунту? Зареєструватися", for: .normal)
        switchModeButton.tintColor = .white
        switchModeButton.addTarget(self, action: #selector(toggleMode), for: .touchUpInside)
        
        stack = UIStackView(arrangedSubviews: [
            logoImageView,
            emailField, passwordField,
            firstNameField, lastNameField, ageField, heightField, weightField,
            actionButton,
            switchModeButton
        ])
        
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            emailField.heightAnchor.constraint(equalToConstant: 40),
            passwordField.heightAnchor.constraint(equalToConstant: 40),
            firstNameField.heightAnchor.constraint(equalToConstant: 40),
            lastNameField.heightAnchor.constraint(equalToConstant: 40),
            ageField.heightAnchor.constraint(equalToConstant: 40),
            heightField.heightAnchor.constraint(equalToConstant: 40),
            weightField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        UIView.animate(withDuration: 1.2,
                       delay: 0.3,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut) {
            self.logoImageView.alpha = 1
            self.logoImageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            UIView.animate(withDuration: 0.5) {
                self.logoImageView.transform = .identity
            }
        }
    }
    
    private func setupValidationChain() {
        let email = EmailValidationHandler()
        let password = PasswordValidationHandler()
        email.setNext(password)
        validationChain = email
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
    }
    
    private func setupPickers() {
        [agePicker, heightPicker, weightPicker].forEach {
            $0.dataSource = self
            $0.delegate = self
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func handleAuth() {
        dismissKeyboard()
        
        guard let email = emailField.text,
              let password = passwordField.text else {
            showAlert(message: "Введіть email і пароль")
            return
        }

        if isLoginMode {
            AuthService.shared.login(email: email, password: password) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let userIn):
                        UserDefaults.standard.set(userIn.token, forKey: "idToken")
                        
                        if userIn.user.status == "Trainer" {
                            let trainerVC = TrainerGymSectionViewController()
                            trainerVC.modalPresentationStyle = .fullScreen
                            self?.present(trainerVC, animated: true)
                        } else {
                            self?.showAlert(title: "Вхід виконано", message: "Ласкаво просимо!") {
                                let mainTabBar = MainTabBarController()
                                mainTabBar.modalPresentationStyle = .fullScreen
                                self?.present(mainTabBar, animated: true)
                            }
                        }
                        
                    case .failure(let error):
                        self?.showAlert(title: "Помилка входу", message: error.localizedDescription)
                    }
                }
            }
        } else {
            registerButtonTapped()
        }

    }
    
    @objc private func toggleMode() {
        isLoginMode.toggle()
        
        UIView.animate(withDuration: 0.4) {
            [self.firstNameField, self.lastNameField, self.ageField, self.heightField, self.weightField].forEach {
                $0.isHidden = self.isLoginMode
            }
        }
        
        actionButton.setTitle(isLoginMode ? "Увійти" : "Зареєструватися", for: .normal)
        switchModeButton.setTitle(
            isLoginMode ? "Немає акаунту? Зареєструватися" : "Вже маєте акаунт? Увійти",
            for: .normal
        )
    }
    
    // Unified alert helper
    private func showAlert(title: String? = nil, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true)
    }
}

extension UIView {
    func applyGradient(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: - UITextFieldDelegate
extension AuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            textField.resignFirstResponder()
            handleAuth()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - UIPickerView DataSource & Delegate
extension AuthViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == agePicker { return 83 } // 18–100
        if pickerView == heightPicker { return 121 } // 140–260 см
        return 171 // 40–210 кг
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == agePicker { return "\(row + 18)" }
        if pickerView == heightPicker { return "\(row + 140) см" }
        return "\(row + 40) кг"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == agePicker { ageField.text = "\(row + 18)" }
        if pickerView == heightPicker { heightField.text = "\(row + 140)" }
        if pickerView == weightPicker { weightField.text = "\(row + 40)" }
    }
    
    private func registerButtonTapped() {
        guard let email = emailField.text,
              let password = passwordField.text,
              let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let age = Int(ageField.text ?? "0"),
              let height = Int(heightField.text ?? "0"),
              let weight = Int(weightField.text ?? "0")
        else {
            showAlert(title: "Помилка", message: "Будь ласка, заповніть усі поля")
            return
        }

        AuthService.shared.register(
            email: email,
            password: password,
            firstName: firstName,
            name: lastName,
            age: age,
            height: height,
            weight: weight
        ) { [weak self] result in
            switch result {
            case .success:
                AuthService.shared.login(email: email, password: password) { loginResult in
                    DispatchQueue.main.async {
                        switch loginResult {
                        case .success:
                            self?.showAlert(title: "Реєстрація та вхід успішні", message: "Гарних тренувань")
                            let mainTabBar = MainTabBarController()
                            mainTabBar.modalPresentationStyle = .fullScreen
                            self?.present(mainTabBar, animated: true)
                        case .failure(let error):
                            self?.showAlert(title: "Помилка входу після реєстрації", message: error.localizedDescription)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert(title: "Реєстрація успішна", message: "Гарних тренувань")
                }
            }
        }

    }
}
