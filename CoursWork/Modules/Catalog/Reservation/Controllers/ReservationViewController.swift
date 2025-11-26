//
//  ReservationViewController.swift
//  CoursWork
//
//  Created by Admin on 03.11.2025.
//

import UIKit
import PassKit

final class ReservationViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {
    
    private let section: GymSection
    private let viewModel: ReservationViewModel
    private let formView = ReservationFormView()
    private let bookingService = BookingService()

    private let infoCardView = UIView()
    private let stackView = UIStackView()
    
    private var pendingUserName: String?
    private var pendingDate: Date?
    private var pendingTimeSlot: String?
    private var payWithPoints = false
    
    init(section: GymSection) {
        self.section = section
        self.viewModel = ReservationViewModel(section: section)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupInfoCard()
        setupForm()
    }

    private func setupInfoCard() {
        infoCardView.translatesAutoresizingMaskIntoConstraints = false
        infoCardView.backgroundColor = UIColor.systemGray6
        infoCardView.layer.cornerRadius = 16
        infoCardView.layer.shadowColor = UIColor.black.cgColor
        infoCardView.layer.shadowOpacity = 0.1
        infoCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        infoCardView.layer.shadowRadius = 4
        view.addSubview(infoCardView)
        
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        infoCardView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            infoCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            infoCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            infoCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: infoCardView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: -16)
        ])
        
        addInfoRow(title: "Section", value: viewModel.sectionName)
        addInfoRow(title: "Sport", value: viewModel.sportType)
        addInfoRow(title: "Difficulty", value: viewModel.difficulty)
        addInfoRow(title: "Age Range", value: viewModel.ageRange)
        addInfoRow(title: "Premium", value: viewModel.isPremium ? "Yes" : "No")
        addInfoRow(title: "trainerName", value: viewModel.trainerName)
        addInfoRow(title: "Gym", value: viewModel.gymName)
        addInfoRow(title: "Address", value: viewModel.gymAddress)
        addInfoRow(title: "Halls", value: viewModel.gymHallsDescription)
    }
    
    private func addInfoRow(title: String, value: String) {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(
            string: "\(title): ",
            attributes: [.font: UIFont.boldSystemFont(ofSize: 16)]
        )
        attributedText.append(NSAttributedString(
            string: value,
            attributes: [.font: UIFont.systemFont(ofSize: 16)]
        ))
        label.attributedText = attributedText
        label.numberOfLines = 0
        stackView.addArrangedSubview(label)
    }

    private func setupForm() {
        view.addSubview(formView)
        formView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            formView.topAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: 24),
            formView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            formView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            formView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        formView.onConfirm = { [weak self] name, date, timeSlot, usePoints in
            self?.payWithPoints = usePoints
            self?.startPaymentFlow(name: name, date: date, timeSlot: timeSlot)
        }
    }
    private func startPaymentFlow(name: String, date: Date, timeSlot: String) {
        pendingUserName = name
        pendingDate = date
        pendingTimeSlot = timeSlot

        let priceUAH = section.price
        let userPoints = UserRepository.shared.getUserProfile().bonusPoints
        let pointsAsUAH =  Double(userPoints) / 100

        if payWithPoints {
            if pointsAsUAH > priceUAH {
                UserRepository.shared.updateBonusPoints(by: -(Int(priceUAH) * 100))
                finishBookingWithoutPayment()
                return
            } else {
                let bonusCoveredUAH = pointsAsUAH
                let remainingUAH = priceUAH - bonusCoveredUAH

                UserRepository.shared.updateBonusPoints(by: -(userPoints))

                startApplePay(amount: Int(remainingUAH))
                return
            }
        }

        startApplePay(amount: Int(priceUAH))
    }

    
    private func startApplePay(amount: Int) {
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [.visa, .masterCard, .amex]) else {
            showAlert(title: "Помилка", message: "Apple Pay недоступний")
            return
        }

        let request = PKPaymentRequest()
        request.merchantIdentifier = "your.merchant.id"
        request.supportedNetworks = [.visa, .masterCard, .amex]
        request.merchantCapabilities = .capability3DS
        request.countryCode = "UA"
        request.currencyCode = "UAH"

        let summary = PKPaymentSummaryItem(label: section.name, amount: NSDecimalNumber(value: amount))
        request.paymentSummaryItems = [summary]

        guard let vc = PKPaymentAuthorizationViewController(paymentRequest: request) else { return }
        vc.delegate = self
        present(vc, animated: true)
    }

    private func finishBookingWithoutPayment() {
        guard let userId = UserDefaults.standard.string(forKey: "id"),
              let name = pendingUserName,
              let date = pendingDate,
              let timeSlot = pendingTimeSlot else { return }

        bookingService.createBooking(
            userId: userId,
            sectionId: section.id,
            userName: name,
            date: date,
            timeSlot: timeSlot
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.showAlert(title: "Успіх", message: "Бронювання оплачено бонусами")
                case .failure:
                    self.showAlert(title: "Помилка", message: "Не вдалося створити бронювання")
                }
            }
        }
    }


    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        guard let userId = UserDefaults.standard.string(forKey: "id"),
            let name = pendingUserName,
            let date = pendingDate,
            let timeSlot = pendingTimeSlot else {
        completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
        return
        }

        bookingService.createBooking(
            userId: userId,
            sectionId: section.id,
            userName: name,
            date: date,
            timeSlot: timeSlot
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let booking):
                    print("Booking created:", booking)
                    completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
                    self.showAlert(title: "Успіх", message: "Бронювання виконано 🥰")
                case .failure(let error):
                    print("Booking error:", error)
                    completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                    self.showAlert(title: "Помилка", message: "Не вдалося створити бронювання 😔")
                }
            }
        }
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
