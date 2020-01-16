//
//  UserDefaults+Extensions.swift
//  NextPomodoro
//
//  Created by ST20638 on 2020/01/16.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Foundation

enum ApplicationSettingsKeys: String {
    case server
    case username
    case broker
    case brokerSSL
    case brokerPort

    case cache
}

extension UserDefaults {
    // MARK: - Getters
    func string(forKey key: ApplicationSettingsKeys) -> String? {
        return string(forKey: key.rawValue)
    }

    func integer(forKey key: ApplicationSettingsKeys) -> Int {
        return integer(forKey: key.rawValue)
    }

    func date(forKey key: ApplicationSettingsKeys) -> Date? {
        return object(forKey: key.rawValue) as? Date
    }

    func bool(forKey key: ApplicationSettingsKeys) -> Bool? {
        return bool(forKey: key.rawValue)
    }

    func url(forKey key: ApplicationSettingsKeys) -> URL? {
        return url(forKey: key.rawValue)
    }

    func object<T: Decodable>(forKey: ApplicationSettingsKeys) -> T? {
        guard let data = data(forKey: forKey.rawValue) else {return nil}
        return try? PropertyListDecoder().decode(T.self, from: data) as T
    }

    // MARK: - Setters
    func set(value: String, forKey key: ApplicationSettingsKeys) {
        set(value, forKey: key.rawValue)
    }

    func set(value: Int, forKey key: ApplicationSettingsKeys) {
        set(value, forKey: key.rawValue)
    }

    func set(value: Date, forKey key: ApplicationSettingsKeys) {
        set(value, forKey: key.rawValue)
    }

    func set(value: Bool, forKey key: ApplicationSettingsKeys) {
        set(value, forKey: key.rawValue)
    }

    func set<T: Encodable>(_ value: T, forKey: ApplicationSettingsKeys) {
        set(try? PropertyListEncoder().encode(value), forKey: forKey.rawValue)
    }

    // MARK: - Other
    func removeObject(forKey key: ApplicationSettingsKeys) {
        removeObject(forKey: key.rawValue)
    }

    func checkDefault(_ defaultValue: String, forKey key: ApplicationSettingsKeys ) {
        if string(forKey: key) == nil {
            set(defaultValue, forKey: key.rawValue)
        }
    }
    func checkDefault(_ defaultValue: Int, forKey key: ApplicationSettingsKeys) {
        if object(forKey: key.rawValue) == nil {
            set(defaultValue, forKey: key.rawValue)
        }
    }
    func checkDefault(_ defaultValue: Bool, forKey key: ApplicationSettingsKeys) {
        if object(forKey: key.rawValue) == nil {
            set(defaultValue, forKey: key.rawValue)
        }
    }
}
