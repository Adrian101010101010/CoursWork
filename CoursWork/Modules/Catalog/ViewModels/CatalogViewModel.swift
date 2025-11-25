//
//  CatalogViewModel.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

import Foundation

final class CatalogViewModel {
    private let repository: SectionRepositoryProtocol
    private var allSections: [GymSection] = []
    private var filteredSections: [GymSection] = [] 
    
    init(repository: SectionRepositoryProtocol) {
        self.repository = repository
    }

    func fetchSections(completion: @escaping () -> Void) {
        repository.fetchAllSections { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let sections):
                    self?.allSections = sections
                    self?.filteredSections = sections
                    completion()
                case .failure(let error):
                    print("Error fetching sections:", error)
                    completion()
                }
            }
        }
    }

    func applyFilter(_ strategy: FilterStrategy) {
        filteredSections = strategy.filter(sections: allSections)
    }

    func getSections() -> [GymSection] {
        return filteredSections
    }
}

