//
//  Log.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/04.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import os
import Foundation

extension OSLog {
    static let favorites = OSLog.init(subsystem: Bundle.main.bundleIdentifier!, category: "Favorites")
    static let pomodoro = OSLog.init(subsystem: Bundle.main.bundleIdentifier!, category: "Pomodoro")
    static let networking = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Networking")
    static let mqtt = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "MQTT")
    static let view = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ViewController")
    static let today = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "TodayWidget")
}
