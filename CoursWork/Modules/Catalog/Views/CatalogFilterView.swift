//
//  CatalogFilterView.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

import UIKit

final class CatalogFilterView: UIView {
    var onFilterSelected: ((FilterStrategy) -> Void)?

    private let segmentedControl: UISegmentedControl = {
        let items = SportType.allCases.map { $0.rawValue }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        return control
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)

        addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        segmentedControl.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
    }

    @objc private func filterChanged() {
        let selectedType = SportType.allCases[segmentedControl.selectedSegmentIndex]
        
        switch selectedType {
        case .all:
            onFilterSelected?(AllSectionsFilterStrategy())
        case .yoga:
            onFilterSelected?(YogaFilterStrategy())
        case .football:
            onFilterSelected?(FootballFilterStrategy())
        case .fitness:
            onFilterSelected?(FitnessFilterStrategy())
        case .swimming:
            onFilterSelected?(SwimmingFilterStrategy())
        }
    }
}
