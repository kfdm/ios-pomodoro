//
//  UserDefaults+Extensions.swift
//  NextPomodoro
//
//  Created by ST20638 on 2020/01/16.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Foundation

extension UserDefaults {
    // MARK: - Getters
    func string(forKey key: UserDefaults.Keys) -> String? {
        return string(forKey: key.rawValue)
    }

    func integer(forKey key: UserDefaults.Keys) -> Int {
        return integer(forKey: key.rawValue)
    }

    func date(forKey key: UserDefaults.Keys) -> Date? {
        return object(forKey: key.rawValue) as? Date
    }

    func bool(forKey key: UserDefaults.Keys) -> Bool? {
        return bool(forKey: key.rawValue)
    }

    func url(forKey key: UserDefaults.Keys) -> URL? {
        return url(forKey: key.rawValue)
    }

    func object<T: Decodable>(forKey: UserDefaults.Keys) -> T? {
        guard let data = data(forKey: forKey.rawValue) else {return nil}
        return try? PropertyListDecoder().decode(T.self, from: data) as T
    }

    // MARK: - Setters
    func set(value: String, forKey key: UserDefaults.Keys) {
        set(value, forKey: key.rawValue)
    }

    func set(value: Int, forKey key: UserDefaults.Keys) {
        set(value, forKey: key.rawValue)
    }

    func set(value: Date, forKey key: UserDefaults.Keys) {
        set(value, forKey: key.rawValue)
    }

    func set(value: Bool, forKey key: UserDefaults.Keys) {
        set(value, forKey: key.rawValue)
    }

    func set<T: Encodable>(_ value: T, forKey: UserDefaults.Keys) {
        set(try? PropertyListEncoder().encode(value), forKey: forKey.rawValue)
    }

    // MARK: - Other
    func removeObject(forKey key: UserDefaults.Keys) {
        removeObject(forKey: key.rawValue)
    }

    func checkDefault(_ defaultValue: String, forKey key: UserDefaults.Keys ) {
        if string(forKey: key) == nil {
            set(defaultValue, forKey: key.rawValue)
        }
    }
    func checkDefault(_ defaultValue: Int, forKey key: UserDefaults.Keys) {
        if object(forKey: key.rawValue) == nil {
            set(defaultValue, forKey: key.rawValue)
        }
    }
    func checkDefault(_ defaultValue: Bool, forKey key: UserDefaults.Keys) {
        if object(forKey: key.rawValue) == nil {
            set(defaultValue, forKey: key.rawValue)
        }
    }
}
