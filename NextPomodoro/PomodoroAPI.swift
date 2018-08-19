//
//  PomodoroModel.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation

struct ApplicationSettingsKeys {
    static let apiKey = "apiKey"
    static let suiteName = "group.net.kungfudiscomonkey.pomodoro"
    static let username = "username"
    static let password = "password"
}


struct ApplicationSettings {
    static let defaults = UserDefaults(suiteName: ApplicationSettingsKeys.suiteName)!
    static let baseURL = "https://tsundere.co/"
    static let pomodoroAPI = "https://tsundere.co/api/pomodoro"
    static let favoriteAPI = "https://tsundere.co/api/favorite"
    static let tokenApi = "https://tsundere.co/api/token/"

    static var username: String? {
        get { return defaults.string(forKey: ApplicationSettingsKeys.username) }
        set { defaults.set(newValue, forKey: ApplicationSettingsKeys.username) }
    }

    static var password: String? {
        get { return defaults.string(forKey: ApplicationSettingsKeys.password) }
        set { defaults.set(newValue, forKey: ApplicationSettingsKeys.password) }
    }
}

struct Favorite: Codable {
    let id: Int
    let title: String
    let duration: Int
    let category: String
    let owner: String
    let icon: String?
    let count: Int
}

struct FavoriteResponse : Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Favorite]
}

struct Pomodoro: Codable {
    let id: Int
    let title: String
    let start: String
    let end: String
    let category: String
    let owner: String
}

struct PomodoroResponse : Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Pomodoro]
}

func checkLogin(username: String, password: String, completionHandler: @escaping (HTTPURLResponse) -> Void) {
    let url = URL.init(string: ApplicationSettings.pomodoroAPI)
    var request = URLRequest.init(url: url!)

    let loginString = "\(username):\(password)"

    guard let loginData = loginString.data(using: String.Encoding.utf8) else {
        return
    }
    let base64LoginString = loginData.base64EncodedString()

    request.httpMethod = "GET"
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
        if let httpResponse = response as? HTTPURLResponse {
            completionHandler(httpResponse)
        }
    })

    task.resume()
}

func getFavorites(completionHandler: @escaping ([Favorite]) -> Void) {
    let url = URL.init(string: ApplicationSettings.favoriteAPI)
    var request = URLRequest.init(url: url!)

    let loginString = "\(ApplicationSettings.username!):\(ApplicationSettings.password!)"

    guard let loginData = loginString.data(using: String.Encoding.utf8) else {
        return
    }
    let base64LoginString = loginData.base64EncodedString()

    request.httpMethod = "GET"
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse)
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let favorites = try decoder.decode(FavoriteResponse.self, from: data!)
                    completionHandler(favorites.results)
                } catch let error {
                    print(error)
                }
            }}
    })

    task.resume()
}

func getHistory(completionHandler: @escaping ([Pomodoro]) -> Void) {
    let url = URL.init(string: ApplicationSettings.pomodoroAPI)
    var request = URLRequest.init(url: url!)

    let loginString = "\(ApplicationSettings.username!):\(ApplicationSettings.password!)"

    guard let loginData = loginString.data(using: String.Encoding.utf8) else {
        return
    }
    let base64LoginString = loginData.base64EncodedString()

    request.httpMethod = "GET"
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error -> Void in
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse)
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let pomodoros = try decoder.decode(PomodoroResponse.self, from: data!)
                    completionHandler(pomodoros.results)
                } catch let error {
                    print(error)
                }
            }}
    })

    task.resume()
}

