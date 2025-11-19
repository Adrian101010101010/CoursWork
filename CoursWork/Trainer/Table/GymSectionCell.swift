//
//  GymSectionCell.swift
//  CoursWork
//
//  Created by Adrian on 18.11.2025.
//

import UIKit

final class GymSectionCell: UITableViewCell {

    static let identifier = "GymSectionCell"

    let nameLabel = UILabel()
    let sportTypeLabel = UILabel()
    let difficultyLabel = UILabel()
    let priceLabel = UILabel()

    let editButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)

    var editAction: (() -> Void)?
    var deleteAction: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [nameLabel, sportTypeLabel, difficultyLabel, priceLabel, editButton, deleteButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])

        editButton.setTitle("Edit", for: .normal)
        deleteButton.setTitle("Delete", for: .normal)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }

    @objc private func editTapped() {
        editAction?()
    }

    @objc private func deleteTapped() {
        deleteAction?()
    }
}
