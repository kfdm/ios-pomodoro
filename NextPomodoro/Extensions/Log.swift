//
//  Log.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/04.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import os
import Foundation

struct Log {
    static let favorites = OSLog.init(subsystem: Bundle.main.bundleIdentifier!, category: "Favorites")
    static let networking = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Networking")
}
