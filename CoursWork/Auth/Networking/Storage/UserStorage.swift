//
//  UserStorage.swift
//  CoursWork
//
//  Created by Adrian on 11.11.2025.
//

import Foundation

final class UserStorage {
    static let shared = UserStorage()
    private let defaults = UserDefaults.standard

    private let userKey = "currentUser"

    func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: userKey)
        }
    }

    func getUser() -> User? {
        guard let data = defaults.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    func clear() {
        defaults.removeObject(forKey: userKey)
    }
}
