//
//  Settings.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/09/09.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation

enum ApplicationSettingsKeys: String {
    case apiKey = "apiKey"
    case baseURL = "baseURL"
    case suiteName = "group.net.kungfudiscomonkey.pomodoro"
    case username = "username"
    case password = "password"
    case cache = "cache"
}

extension UserDefaults {
    func string(forKey: ApplicationSettingsKeys) -> String? {
        return string(forKey: forKey.rawValue)
    }
    func set(_ value: String?, forKey: ApplicationSettingsKeys) {
        set(value, forKey: forKey.rawValue)
    }
    func value(forKey: ApplicationSettingsKeys) -> Any? {
        return value(forKey: forKey.rawValue)
    }
    func set(_ value: Data?, forKey: ApplicationSettingsKeys) {
        set(value, forKey: forKey.rawValue)
    }
}

struct ApplicationSettings {
    static let defaults = UserDefaults(suiteName: ApplicationSettingsKeys.suiteName.rawValue)!

    static var baseURL: String {
        return defaults.string(forKey: .baseURL) ?? "https://tsundere.co/"
    }

    static var username: String? {
        get { return defaults.string(forKey: .username) }
        set { defaults.set(newValue, forKey: .username) }
    }

    static var password: String? {
        get { return defaults.string(forKey: .password) }
        set { defaults.set(newValue, forKey: .password) }
    }

    static var cache: Pomodoro? {
        get {
            guard let data = defaults.value(forKey: .cache) as? Data else {return nil}
            return try? PropertyListDecoder().decode(Pomodoro.self, from: data)
        }
        set {
            defaults.set(try? PropertyListEncoder().encode(newValue), forKey: .cache)
        }
    }

    static var shortDateTime: DateFormatter {
        let dateFormat = DateFormatter()
        dateFormat.locale = NSLocale.current
        dateFormat.dateStyle = .short
        dateFormat.timeStyle = .short
        dateFormat.timeZone = TimeZone.current
        return dateFormat
    }

    static var mediumDateTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone.current
        return formatter
    }

    static var shortTime: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }

    static func decode<T>(_ type: T.Type, from data: Data) throws -> T? where T: Decodable {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(dateDecode)
        return try? decoder.decode(T.self, from: data)
    }
}

extension ApplicationSettings {
    func saveLogin(username: String, password: String) {

    }

    static func deleteLogin() {
        ApplicationSettings.username = nil
        ApplicationSettings.password = nil
        ApplicationSettings.cache = nil
    }
}
