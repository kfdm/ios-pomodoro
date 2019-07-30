//
//  PomodoroModel.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation

func checkLogin(username: String, password: String, completionHandler: @escaping (HTTPURLResponse) -> Void) {
    authedRequest(path: "/api/pomodoro", method: "GET", body: nil, username: username, password: password, completionHandler: {response, _ in
        completionHandler(response)
    })
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

typealias AuthedRequestResponse = ((HTTPURLResponse, Data) -> Void)

func authedRequest(path: String, method: String, body: Data?, username: String, password: String, completionHandler: @escaping AuthedRequestResponse) {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "tsundere.co"
    components.path = path

    authedRequest(url: components.url!, method: method, body: body, username: username, password: password, completionHandler: completionHandler)
}

func authedRequest(url: URL, method: String, body: Data?, username: String, password: String, completionHandler: @escaping AuthedRequestResponse) {
    var request = URLRequest(url: url)

    let loginString = "\(username):\(password)"
    guard let loginData = loginString.data(using: String.Encoding.utf8) else {
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
            completionHandler(httpResponse, data!)
        }
    })

    task.resume()
}
