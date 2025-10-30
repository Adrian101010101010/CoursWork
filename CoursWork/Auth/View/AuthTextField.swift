//
//  AuthTextField.swift
//  CoursWork
//
//  Created by Admin on 28.10.2025.
//

import UIKit

final class AuthTextField: UITextField {
    init(placeholder: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.isSecureTextEntry = isSecure
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray4.cgColor
        self.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
        self.setLeftPadding(12)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) { fatalError() }
}

private extension UITextField {
    func setLeftPadding(_ amount: CGFloat) {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: 10))
        leftViewMode = .always
    }
}
