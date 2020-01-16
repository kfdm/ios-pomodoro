//
//  JSON+Extensions.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2020/01/05.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import Foundation

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

extension Data {
    func toString(encoding: String.Encoding = .utf8) -> String? {
        return String(data: self, encoding: encoding)
    }
}

extension Encodable {
    func toData() -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            return try encoder.encode(self)
        } catch let error {
            print(error)
        }
        return nil
    }
    func toString() -> String? {
        guard let data = toData() else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

extension Decodable {
    static func fromData<T: Decodable>(_ message: Data) -> T? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(dateDecode)
        do {
            return try decoder.decode(T.self, from: message)
        } catch let error {
            print(error)
            return nil
        }
    }

    static func fromString<T: Decodable>(_ message: String) -> T? {
        return fromData(message.data(using: .utf8)!)
    }
}
