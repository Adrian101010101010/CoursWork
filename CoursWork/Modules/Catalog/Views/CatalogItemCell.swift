//
//  CatalogItemCell.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

import UIKit
import SwiftUI

final class CatalogItemCell: UITableViewCell {
    static let identifier = "CatalogItemCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(with section: GymSection) {
        backgroundColor = .clear
        self.contentConfiguration = UIHostingConfiguration {
            CatalogItemView(section: section)
                .padding(.vertical, 6)
        }
    }
}

struct CatalogItemView: View {
    let section: GymSection
    @State private var animate = false

    var body: some View {
        ZStack(alignment: .topTrailing) {

            mainContent

            if isNew {
                Text("NEW")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .padding(8)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var isNew: Bool {
        guard let created = section.createdAt.toISODate() else { return false }
        return created.isToday
    }

    private var mainContent: some View {
        HStack(spacing: 12) {
            Image("Logo")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .background(Color(.systemGray6))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(PremiumSectionDecorator(section: section).displayName())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.primary)
                Text("\(section.sportType.rawValue) • \(section.difficulty.rawValue)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()
            
            Text(section.isPremium ? "PREMIUM" : "STANDARD")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(section.isPremium ? .yellow : .gray)
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

extension String {
    func toISODate() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter.date(from: self)
    }
}


extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}
