//
//  SubscriptionItemCell.swift
//  CoursWork
//
//  Created by Adrian on 04.11.2025.
//

import UIKit
import SwiftUI

final class SubscriptionItemCell: UITableViewCell {
    static let identifier = "SubscriptionItemCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(with offer: SubscriptionOffer) {
        backgroundColor = .clear
        self.contentConfiguration = UIHostingConfiguration {
            SubscriptionItemView(offer: offer)
                .padding(.vertical, 6)
        }
    }
}

struct SubscriptionItemView: View {
    let offer: SubscriptionOffer
    @State private var animate = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: offer.isPremium ? "star.fill" : "person.crop.rectangle")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
                .foregroundColor(offer.isPremium ? .yellow : .blue)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(offer.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
                Text("\(offer.type) • \(offer.price)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(offer.perks.joined(separator: ", "))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            Spacer()
            
            Text(offer.isPremium ? "PREMIUM" : "STANDARD")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(offer.isPremium ? .yellow : .gray)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
                .imageScale(.small)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(liquidGlassBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
    }
    
    private var liquidGlassBackground: some View {
        ZStack {
            LinearGradient(
                colors: animate ?
                    [Color.blue.opacity(0.25), Color.purple.opacity(0.25), Color.teal.opacity(0.25)] :
                    [Color.pink.opacity(0.25), Color.indigo.opacity(0.25), Color.green.opacity(0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blur(radius: 40)
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)
            .onAppear { animate.toggle() }

            Rectangle()
                .fill(.ultraThinMaterial)
                .blendMode(.overlay)

            LinearGradient(
                colors: [Color.white.opacity(0.15), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .compositingGroup()
    }
}
