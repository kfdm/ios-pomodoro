//
//  Settings.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/09/09.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import  Foundation
import KeychainAccess

struct ApplicationSettings {
    static let identifier = "group.net.kungfudiscomonkey.pomodoro"
    static let defaults = UserDefaults(suiteName: ApplicationSettings.identifier)!
    static let keychain = Keychain(accessGroup: ApplicationSettings.identifier)

    static func loadDefaults() {
        ApplicationSettings.defaults.checkDefault("tsundere.co", forKey: .server)
        ApplicationSettings.defaults.checkDefault(8883, forKey: .brokerPort)
        ApplicationSettings.defaults.checkDefault(true, forKey: .brokerSSL)
    }

    static var lastPomodoro: Pomodoro? {
        get {
            guard let data = defaults.value(forKey: ApplicationSettingsKeys.cache.rawValue) as? Data else {return nil}
            return try? PropertyListDecoder().decode(Pomodoro.self, from: data)
        }
        set {
            defaults.set(try? PropertyListEncoder().encode(newValue), forKey: ApplicationSettingsKeys.cache.rawValue)
        }
    }

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
        defaults.removeSuite(named: ApplicationSettings.identifier)
    }
}
