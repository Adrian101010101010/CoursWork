//
//  SectionRepositoryProtocol.swift
//  CoursWork
//
//  Created by Admin on 30.10.2025.
//

protocol SectionRepositoryProtocol {
    func fetchAllSections(completion: @escaping (Result<[GymSection], Error>) -> Void)
}
