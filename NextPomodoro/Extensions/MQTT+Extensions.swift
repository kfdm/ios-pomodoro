//
//  MQTT+Extensions.swift
//  nagger
//
//  Created by Paul Traylor on 2020/01/05.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftMQTT
import Foundation

extension MQTTMessage {
    /// Match an MQTT Message with a regular expression pattern
    /// - Parameter pattern: Regular expression
    func match(_ pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return false}
        return regex.numberOfMatches(in: self.topic, options: .anchored, range: .init(self.topic.startIndex..., in: self.topic)) > 0
    }

    var data: Data {
        return Data(payload)
    }
}

extension MQTTSession {
    static func connectionFactory() -> Result<MQTTSession, Error> {
        let clientID = "MacNagger-" + String(ProcessInfo().processIdentifier)
        let host = ApplicationSettings.defaults.string(forKey: .server)!
        let port = UInt16(ApplicationSettings.defaults.integer(forKey: .brokerPort))
        let mqtt = MQTTSession(host: host, port: port, clientID: clientID, cleanSession: true, keepAlive: 15, useSSL: true)
        mqtt.username = ApplicationSettings.defaults.string(forKey: .username)
        mqtt.password = ApplicationSettings.keychain.string(forKey: .broker)
        return .success(mqtt)
    }
}
