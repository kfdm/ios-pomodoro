//
//  ApplicationSettings.swift
//  pomodoro
//
//  Created by Paul Traylor on 2017/07/23.
//  Copyright © 2017年 Paul Traylor. All rights reserved.
//

import  Foundation

struct ApplicationSettingsKeys {
    static let apiKey = "apiKey"
    static let suiteName = "group.net.kungfudiscomonkey.pomodoro"
}

struct ApplicationSettings {
    static let defaults = UserDefaults(suiteName: ApplicationSettingsKeys.suiteName)!
    static let homeURL = "https://tsundere.co/pomodoro"
    static let pomodoroAPI = "https://tsundere.co/api/pomodoro"
    static let tokenApi = "https://tsundere.co/api/token/"

    static var apiKey: String? {
        get { return defaults.string(forKey: ApplicationSettingsKeys.apiKey) }
        set { defaults.set(newValue, forKey: ApplicationSettingsKeys.apiKey) }
    }
}
