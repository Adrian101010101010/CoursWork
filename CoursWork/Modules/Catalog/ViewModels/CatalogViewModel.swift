//
//  CatalogViewModel.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

import Foundation

final class CatalogViewModel {
    private let repository: SectionRepositoryProtocol
    private var sections: [GymSection] = []
    private var currentFilter: FilterStrategy?

    var onUpdate: (() -> Void)?

    init(repository: SectionRepositoryProtocol) {
        self.repository = repository
        self.sections = repository.fetchAllSections()
    }

    func applyFilter(_ strategy: FilterStrategy) {
        currentFilter = strategy
        sections = strategy.filter(sections: repository.fetchAllSections())
        onUpdate?()
    }

    func getSections() -> [GymSection] {
        return sections
    }
}
