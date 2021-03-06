//
//  APIBase.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation
import os

protocol EncodableJson: Codable {
    func encode() -> Data?
}

protocol DecodableJson: Decodable {
    static func decode<T: DecodableJson>(from Data: Data) -> T?
}

extension EncodableJson {
    func encode() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(self)
            return data
        } catch let error {
            os_log("Error encoding: %s", log: Log.networking, type: .error, error.localizedDescription)
        }
        return nil
    }
}

extension DecodableJson {
    static func decode<T>(from data: Data) -> T? where T: DecodableJson {
        let decoder = JSONDecoder()
        // https://stackoverflow.com/a/46538676
        decoder.dateDecodingStrategy = .custom(dateDecode)
        do {
            return try decoder.decode(T.self, from: data)
        } catch let error {
            os_log("Error decoding: %s", log: Log.networking, type: .error, error.localizedDescription)
        }
        return nil
    }
}

enum DateError: String, Error {
    case invalidDate
}

func dateDecode(decoder: Decoder) throws -> Date {
    let container = try decoder.singleValueContainer()
    let dateStr = try container.decode(String.self)

    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    if let date = formatter.date(from: dateStr) {
        return date
    }
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
    if let date = formatter.date(from: dateStr) {
        return date
    }
    throw DateError.invalidDate
}
