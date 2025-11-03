//
//  ReservationViewController.swift
//  CoursWork
//
//  Created by Admin on 03.11.2025.
//

import UIKit

final class ReservationViewController: UIViewController {
    private let viewModel: ReservationViewModel
    private let formView = ReservationFormView()

    init(section: GymSection) {
        self.viewModel = ReservationViewModel(section: section)
        super.init(nibName: nil, bundle: nil)
        title = "Резервування"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground

        let headerLabel = UILabel()
        headerLabel.text = "\(viewModel.sectionName)\n\(viewModel.sportType) • \(viewModel.difficulty)"
        headerLabel.numberOfLines = 2
        headerLabel.font = .boldSystemFont(ofSize: 22)
        headerLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [headerLabel, formView])
        stack.axis = .vertical
        stack.spacing = 20
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        formView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            formView.heightAnchor.constraint(equalToConstant: 250)
        ])

        formView.onConfirm = { [weak self] name, date, timeSlot in
            guard let self else { return }
            let reservation = self.viewModel.reserve(for: name, date: date, timeSlot: timeSlot)
            self.showConfirmation(for: reservation)
        }
    }

    private func showConfirmation(for reservation: Reservation) {
        let alert = UIAlertController(
            title: "✅ Бронювання підтверджено",
            message: """
            \(reservation.section.name)
            Дата: \(formattedDate(reservation.date))
            Час: \(reservation.timeSlot)
            На ім’я: \(reservation.userName)
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
