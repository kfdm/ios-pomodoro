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
    static let pomodoroLabel = "label"
    static let pomodoroId = "id"
    static let pomodoroCategory = "category"
    static let pomodoroDate = "date"
}

struct ApplicationSettings {
    static let defaults = UserDefaults(suiteName: ApplicationSettingsKeys.suiteName)!
    static let homeURL = "https://tsundere.co/pomodoro"
    static let pomodoroAPI = "https://tsundere.co/api/pomodoro"
    static let logoutUrl = "https://tsundere.co/logout"
    static let tokenApi = "https://tsundere.co/api/token/"

    static var apiKey: String? {
        get { return defaults.string(forKey: ApplicationSettingsKeys.apiKey) }
        set { defaults.set(newValue, forKey: ApplicationSettingsKeys.apiKey) }
    }

    static var lastPomodoro: Pomodoro? {
        get {
            if let id = defaults.string(forKey: ApplicationSettingsKeys.pomodoroId) {
                let title = defaults.string(forKey: ApplicationSettingsKeys.pomodoroLabel)!
                let category = defaults.string(forKey: ApplicationSettingsKeys.pomodoroCategory)!
                let end = defaults.object(forKey: ApplicationSettingsKeys.pomodoroDate) as! Date
                return Pomodoro(id: id, title: title, category: category, end: end)
            }
            return nil
        }
        set {
            defaults.set(newValue!.id, forKey: ApplicationSettingsKeys.pomodoroId)
            defaults.set(newValue!.title, forKey: ApplicationSettingsKeys.pomodoroLabel)
            defaults.set(newValue!.category, forKey: ApplicationSettingsKeys.pomodoroCategory)
            defaults.set(newValue!.end, forKey: ApplicationSettingsKeys.pomodoroDate)
        }
    }
}
