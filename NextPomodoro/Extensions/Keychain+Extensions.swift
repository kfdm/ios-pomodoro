//
//  Keychain+Extensions.swift
//  NextPomodoro
//
//  Created by ST20638 on 2020/01/16.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Foundation
import KeychainAccess

enum ApplicationPasswords: String {
    case server
    case broker
}

extension Keychain {
    func string(forKey key: ApplicationPasswords) -> String? {
        return try? get(key.rawValue)
    }
    func set(_ value: String, forKey key: ApplicationPasswords) {
        try? set(value, key: key.rawValue)
    }
}
