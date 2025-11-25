//
//  SubscriptionManagementView.swift
//  CoursWork
//
//  Created by Adrian on 04.11.2025.
//

import UIKit
import CoreImage.CIFilterBuiltins

final class SubscriptionManagementView: UIView {

    private let loyaltyCardView = UIView()
    private let cardTypeLabel = UILabel()
    private let bonusLabel = UILabel()
    private let perksLabel = UILabel()
    
    private let bookingsStack = UIStackView()

    private let bookingService = ProfileNetworkManager.shared
    private var allBookings: [SeasonTicketBooking] = []
    
    private var collapsedHeightConstraints: [Int: NSLayoutConstraint] = [:]
    private var expandedBottomConstraints: [Int: NSLayoutConstraint] = [:]
    private var expandedZeroHeightConstraints: [Int: NSLayoutConstraint] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLoyaltyCard()
        loadBookings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func loadBookings() {
        guard let userId = UserDefaults.standard.string(forKey: "id") else { return }

        bookingService.fetchBookings(for: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let bookings):
                    self?.allBookings = bookings
                    self?.updateBookingsListUI()
                case .failure(let error):
                    print("Failed to fetch bookings:", error)
                }
            }
        }
    }

    private func setupUI() {
        backgroundColor = .systemBackground

        bookingsStack.axis = .vertical
        bookingsStack.spacing = 10
        bookingsStack.alignment = .fill
        bookingsStack.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [
            loyaltyCardView,
            bookingsStack
        ])

        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            loyaltyCardView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),
            bookingsStack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.85),

            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func updateBookingsListUI() {
        bookingsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        collapsedHeightConstraints.removeAll()
        expandedBottomConstraints.removeAll()
        expandedZeroHeightConstraints.removeAll()
        
        for (index, booking) in allBookings.enumerated() {
            let container = UIView()
            container.layer.cornerRadius = 12
            container.backgroundColor = UIColor.systemGray6
            container.translatesAutoresizingMaskIntoConstraints = false
            
            let collapsedHeight = container.heightAnchor.constraint(equalToConstant: 72)
            collapsedHeight.isActive = true
            collapsedHeightConstraints[index] = collapsedHeight
            
            let titleLabel = UILabel()
            titleLabel.numberOfLines = 2
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            titleLabel.text = "Назва: \(booking.name)\nТип: \(booking.type)"
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            titleLabel.setContentHuggingPriority(.required, for: .vertical)
            container.addSubview(titleLabel)
            
            let titleBottomLEQ = titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -12)
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
                titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
                titleBottomLEQ
            ])
            
            let expandedStack = UIStackView()
            expandedStack.axis = .vertical
            expandedStack.spacing = 8
            expandedStack.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(expandedStack)
            
            let priceLabel = UILabel()
            priceLabel.font = .systemFont(ofSize: 14)
            priceLabel.text = "Ціна: \(booking.price)"
            
            let perksLabel = UILabel()
            perksLabel.font = .systemFont(ofSize: 14)
            perksLabel.numberOfLines = 0
            perksLabel.text = "Переваги: \(booking.perks.joined(separator: ", "))"
            
            let qrImageView = UIImageView()
            qrImageView.contentMode = .scaleAspectFit
            qrImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            qrImageView.image = generateQRCode(from: booking.id)
            
            expandedStack.addArrangedSubview(priceLabel)
            expandedStack.addArrangedSubview(perksLabel)
            expandedStack.addArrangedSubview(qrImageView)
            
            let top = expandedStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
            let leading = expandedStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12)
            let trailing = expandedStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
            let bottom = expandedStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
            expandedBottomConstraints[index] = bottom
            
            NSLayoutConstraint.activate([top, leading, trailing])
            let zeroHeight = expandedStack.heightAnchor.constraint(equalToConstant: 0)
            zeroHeight.isActive = true
            expandedZeroHeightConstraints[index] = zeroHeight
            
            expandedStack.isHidden = true
            expandedStack.alpha = 0
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleBookingTap(_:)))
            container.addGestureRecognizer(tap)
            container.isUserInteractionEnabled = true
            container.tag = index
            
            bookingsStack.addArrangedSubview(container)
        }
    }

    @objc private func handleBookingTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let index = view.tag
        
        guard let expandedStack = view.subviews.compactMap({ $0 as? UIStackView }).first else { return }
        let willExpand = expandedStack.isHidden
        
        if willExpand {
            collapsedHeightConstraints[index]?.isActive = false
            expandedZeroHeightConstraints[index]?.isActive = false
            expandedBottomConstraints[index]?.isActive = true
            
            expandedStack.isHidden = false
            expandedStack.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                expandedStack.alpha = 1
                self.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                expandedStack.alpha = 0
                self.layoutIfNeeded()
            }, completion: { _ in
                expandedStack.isHidden = true
                self.expandedBottomConstraints[index]?.isActive = false
                self.expandedZeroHeightConstraints[index]?.isActive = true
                self.collapsedHeightConstraints[index]?.isActive = true
                UIView.animate(withDuration: 0.2) {
                    self.layoutIfNeeded()
                }
            })
        }
    }

    private func setupLoyaltyCard() {
        let user = UserRepository.shared.getUserProfile()

        loyaltyCardView.layer.cornerRadius = 16
        loyaltyCardView.layer.shadowOpacity = 0.2
        loyaltyCardView.layer.shadowRadius = 6
        loyaltyCardView.layer.shadowOffset = .init(width: 0, height: 2)

        switch user.cardType {
        case .standard: loyaltyCardView.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.8)
        case .premium: loyaltyCardView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.3)
        case .corporate: loyaltyCardView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.25)
        }

        cardTypeLabel.text = "Картка: \(user.cardType.rawValue)"
        cardTypeLabel.font = .boldSystemFont(ofSize: 18)

        bonusLabel.text = "Бонусні бали: \(user.bonusPoints)"
        bonusLabel.font = .systemFont(ofSize: 16)
        bonusLabel.textColor = .secondaryLabel

        perksLabel.text = "Переваги: \(user.cardType.perks.joined(separator: ", "))"
        perksLabel.font = .systemFont(ofSize: 14)
        perksLabel.textColor = .secondaryLabel
        perksLabel.numberOfLines = 0

        let vStack = UIStackView(arrangedSubviews: [cardTypeLabel, bonusLabel, perksLabel])
        vStack.axis = .vertical
        vStack.spacing = 6
        vStack.alignment = .leading
        vStack.translatesAutoresizingMaskIntoConstraints = false

        loyaltyCardView.addSubview(vStack)

        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: loyaltyCardView.topAnchor, constant: 12),
            vStack.leadingAnchor.constraint(equalTo: loyaltyCardView.leadingAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: loyaltyCardView.trailingAnchor, constant: -16),
            vStack.bottomAnchor.constraint(equalTo: loyaltyCardView.bottomAnchor, constant: -12)
        ])
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        if let ciImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 5, y: 5)
            let scaled = ciImage.transformed(by: transform)
            return UIImage(ciImage: scaled)
        }
        return nil
    }
}
