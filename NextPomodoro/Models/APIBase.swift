//
//  APIBase.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation
import os

class API {
    typealias HttpResult = (Result<Data, Error>) -> Void
    enum Errors: Error {
        case MissingUser
        case MissingPassword
        case MissingHost
    }
    static var shared = API()

    func authedRequest(path: String, method: String, body: Data? = nil, queryItems: [URLQueryItem]? = [], completionHandler: @escaping HttpResult) {
        guard let host = ApplicationSettings.defaults.string(forKey: .server) else {
            completionHandler(.failure(API.Errors.MissingHost))
            return }
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        components.queryItems = queryItems

        authedRequest(url: components, method: method, body: body, handler: completionHandler)
    }

    func authedRequest(url: URLComponents, method: String, body: Data?, handler: @escaping HttpResult) {
        guard let username = ApplicationSettings.defaults.string(forKey: .username) else {
            handler(.failure(API.Errors.MissingUser))
            return }
        guard let password = ApplicationSettings.keychain.string(forKey: .server) else {
            handler(.failure(API.Errors.MissingPassword))
            return }

        var request = URLRequest(url: url.url!)

        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: String.Encoding.utf8) else {
            print("failed loggin")
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        request.httpMethod = method
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, _ -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                os_log("Request: %s %s %d", log: Log.networking, type: .debug, method, httpResponse.url!.absoluteString, httpResponse.statusCode)
                handler(.success(data!))
            }
        })
        task.resume()
    }
}

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
