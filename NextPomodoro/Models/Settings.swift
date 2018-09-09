//
//  Settings.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/09/09.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation

struct ApplicationSettingsKeys {
    static let apiKey = "apiKey"
    static let baseURL = "baseURL"
    static let suiteName = "group.net.kungfudiscomonkey.pomodoro"
    static let username = "username"
    static let password = "password"
}
struct ApplicationSettings {
    static let defaults = UserDefaults(suiteName: ApplicationSettingsKeys.suiteName)!

    static var baseURL: String {
        return defaults.string(forKey: ApplicationSettingsKeys.baseURL) ?? "https://tsundere.co/"
    }

    static var username: String? {
        get { return defaults.string(forKey: ApplicationSettingsKeys.username) }
        set { defaults.set(newValue, forKey: ApplicationSettingsKeys.username) }
    }

    static var password: String? {
        get { return defaults.string(forKey: ApplicationSettingsKeys.password) }
        set { defaults.set(newValue, forKey: ApplicationSettingsKeys.password) }
    }

    static var cache: Pomodoro? {
        get {
            guard let data = defaults.value(forKey: "cache") as? Data else {return nil}
            return try? PropertyListDecoder().decode(Pomodoro.self, from: data)
        }
        set {
            defaults.set(try? PropertyListEncoder().encode(newValue), forKey: "cache")
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
}
