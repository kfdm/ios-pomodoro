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
    func url(forKey: ApplicationDomainKeys) -> URLComponents? {
        guard let url = string(forKey: forKey) else { return nil }
        return URLComponents(string: url)
    }

    func object<T>(forKey: ApplicationDomainKeys) -> T? where T: Decodable {
        guard let data = data(forKey: forKey.rawValue) else {return nil}
        return try? PropertyListDecoder().decode(T.self, from: data) as T
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

    func cache<T>(_ value: T, forKey: ApplicationDomainKeys) where T: Encodable {
        set(try? PropertyListEncoder().encode(value), forKey: forKey.rawValue)
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
    static let repository = URL(string: "https://github.com/kfdm/ios-pomodoro")!

    static func shortTime(_ duration: Int) -> String? {
        return shortTime(TimeInterval(duration))
    }

    static func shortTime(_ duration: TimeInterval) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration)
    }

    static func shortTime(_ start: Date, _ end: Date) -> String? {
        let duration = end.timeIntervalSince(start)
        return shortTime(duration)
    }

    static func mediumDate(_ date: Date) -> String? {
        let dateFormat = DateFormatter()
        dateFormat.locale = NSLocale.current
        dateFormat.dateStyle = .short
        dateFormat.timeStyle = .short
        dateFormat.timeZone = TimeZone.current
        return dateFormat.string(from: date)
    }
}

extension ApplicationSettings {
    func saveLogin(username: String, password: String) {

    }

    static func deleteLogin() {
        defaults.removeSuite(named: ApplicationDomainKeys.suiteName.rawValue)
    }
}
