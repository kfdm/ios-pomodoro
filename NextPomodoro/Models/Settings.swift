//
//  Settings.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/09/09.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import KeychainAccess

enum ApplicationDomainKeys: String {
    case suiteName = "group.net.kungfudiscomonkey.pomodoro"

    case server
    case username
    case broker
    case brokerSSL
    case brokerPort

    case cache
}

enum ApplicationPasswords: String {
    case server
    case broker
}

extension UserDefaults {
    func string(forKey: ApplicationDomainKeys) -> String? {
        return string(forKey: forKey.rawValue)
    }
    func value(forKey: ApplicationDomainKeys) -> Any? {
        return value(forKey: forKey.rawValue)
    }
    func bool(forKey key: ApplicationDomainKeys) -> Bool {
        return bool(forKey: key.rawValue)
    }
    func integer(forKey key: ApplicationDomainKeys) -> Int {
        return integer(forKey: key.rawValue)
    }

    func set(_ value: String?, forKey: ApplicationDomainKeys) {
        set(value, forKey: forKey.rawValue)
    }
    func set(_ value: Int?, forKey key: ApplicationDomainKeys) {
        set(value, forKey: key.rawValue)
    }
    func set(_ value: Bool, forKey key: ApplicationDomainKeys) {
        set(value, forKey: key.rawValue)
    }
    func set(_ value: Data?, forKey: ApplicationDomainKeys) {
        set(value, forKey: forKey.rawValue)
    }
}

extension Keychain {
    func string(forKey key: ApplicationPasswords) -> String? {
        return try? get(key.rawValue)
    }
    func set(_ value: String, forKey key: ApplicationPasswords) {
        try? set(value, key: key.rawValue)
    }
}

struct ApplicationSettings {
    static let defaults = UserDefaults(suiteName: ApplicationDomainKeys.suiteName.rawValue)!
    static let keychain = Keychain(accessGroup: ApplicationDomainKeys.suiteName.rawValue)

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
        defaults.removeSuite(named: ApplicationDomainKeys.suiteName.rawValue)
    }
}
