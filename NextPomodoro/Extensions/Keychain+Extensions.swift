//
//  Keychain+Extensions.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2020/01/16.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Foundation
import KeychainAccess

extension Keychain {
    func string(forKey key: Keychain.Keys) -> String? {
        return try? get(key.rawValue)
    }
    func set(_ value: String, forKey key: Keychain.Keys) {
        try? set(value, key: key.rawValue)
    }
}
