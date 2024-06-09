//
//  CacheManager.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 9.06.2024.
//

import Foundation

final class CacheManager {
    static let shared: CacheManager = CacheManager()
    private let userDefaults = UserDefaults.standard

    // MARK: - PRIVATE FUNCTIONS

    private init() {}

    // MARK: - INTERNAL FUNCTIONS

    func saveData(_ data: Any, forKey key: CacheConstants) {
        userDefaults.set(data, forKey: key.rawValue)
    }

    func getData(forKey key: CacheConstants) -> Any? {
        return userDefaults.object(forKey: key.rawValue)
    }

    func deleteData(forKey key: CacheConstants) {
        userDefaults.removeObject(forKey: key.rawValue)
    }

    func hasData(forKey key: CacheConstants) -> Bool {
        return userDefaults.object(forKey: key.rawValue) != nil
    }
}

