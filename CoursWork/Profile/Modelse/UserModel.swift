//
//  UserModel.swift
//  CoursWork
//
//  Created by Adrian on 23.11.2025.
//

struct UserModel: Codable {
    let name: String?
    let firstName: String?
    let email: String?
    let age: Int?
    let height: Int?
    let weight: Int?
    let status: String?
}

struct UserResponse: Codable {
    let success: Bool
    let user: UserModel
}
