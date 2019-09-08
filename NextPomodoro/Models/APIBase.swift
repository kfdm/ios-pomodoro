//
//  APIBase.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation

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
            print(error)
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
            print(error)
        }
        return nil
    }
}
