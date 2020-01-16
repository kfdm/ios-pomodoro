//
//  PomodoroModel.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import os

typealias AuthedRequestResponse = ((HTTPURLResponse, Data) -> Void)

func checkLogin(baseURL: String, username: String, password: String, completionHandler: @escaping (HTTPURLResponse) -> Void) {
    var base = URLComponents(string: baseURL)!
    base.path = "/api/pomodoro"
    authedRequest(url: base, method: "GET", body: nil, username: username, password: password, completionHandler: {response, _ in
        completionHandler(response)
    })
}

func authedRequest(path: String, method: String, body: Data? = nil, queryItems: [URLQueryItem]? = [], username: String, password: String, completionHandler: @escaping AuthedRequestResponse) {
    guard let host = ApplicationSettings.defaults.string(forKey: .server) else { print("missing host"); return }
    var components = URLComponents()
    components.scheme = "https"
    components.host = host
    components.path = path
    components.queryItems = queryItems

    authedRequest(url: components, method: method, body: body, username: username, password: password, completionHandler: completionHandler)
}

func authedRequest(url: URLComponents, method: String, body: Data?, username: String, password: String, completionHandler: @escaping AuthedRequestResponse) {
    print("authed request")
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
        print("running task?")
        print(data)
        if let httpResponse = response as? HTTPURLResponse {
            os_log("Request: %s %s %d", log: Log.networking, type: .debug, method, httpResponse.url!.absoluteString, httpResponse.statusCode)
            completionHandler(httpResponse, data!)
        }
        print(response)
    })
    task.resume()
    print("running task")
}
