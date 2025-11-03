//
//  CompositeFilter.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

final class CompositeFilter: FilterStrategy {
    private var filters: [FilterStrategy] = []

    func add(_ filter: FilterStrategy) {
        filters.append(filter)
    }

    func filter(sections: [GymSection]) -> [GymSection] {
        var filtered = sections
        for filter in filters {
            filtered = filter.filter(sections: filtered)
        }
        return filtered
    }
}
