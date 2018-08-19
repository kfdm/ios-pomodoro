//
//  PomodoroModel.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation

struct ApplicationSettingsKeys {
    static let apiKey = "apiKey"
    static let suiteName = "group.net.kungfudiscomonkey.pomodoro"
    static let username = "username"
    static let password = "password"
}


struct ApplicationSettings {
    static let defaults = UserDefaults(suiteName: ApplicationSettingsKeys.suiteName)!
    static let pomodoroAPI = "https://tsundere.co/api/pomodoro"
    static let favoriteAPI = "https://tsundere.co/api/favorite"

    static var username: String? {
        get { return defaults.string(forKey: ApplicationSettingsKeys.username) }
        set { defaults.set(newValue, forKey: ApplicationSettingsKeys.username) }
    }

    static var password: String? {
        get { return defaults.string(forKey: ApplicationSettingsKeys.password) }
        set { defaults.set(newValue, forKey: ApplicationSettingsKeys.password) }
    }
}
