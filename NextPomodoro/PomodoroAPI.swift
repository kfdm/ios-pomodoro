//
//  PomodoroModel.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

struct ApplicationSettingsKeys {
    static let apiKey = "apiKey"
    static let baseURL = "baseURL"
    static let suiteName = "group.net.kungfudiscomonkey.pomodoro"
    static let username = "username"
    static let password = "password"
}
struct ApplicationSettings {
    static let defaults = UserDefaults(suiteName: ApplicationSettingsKeys.suiteName)!

    static var baseURL: String {
        return defaults.string(forKey: ApplicationSettingsKeys.baseURL) ?? "https://tsundere.co/"
    }

    static var username: String? {
        get { return defaults.string(forKey: ApplicationSettingsKeys.username) }
        set { defaults.set(newValue, forKey: ApplicationSettingsKeys.username) }
    }

    static var password: String? {
        get { return defaults.string(forKey: ApplicationSettingsKeys.password) }
        set { defaults.set(newValue, forKey: ApplicationSettingsKeys.password) }
    }

    static var cache: Pomodoro? {
        get {
            guard let data = defaults.value(forKey: "cache") as? Data else {return nil}
            return try? PropertyListDecoder().decode(Pomodoro.self, from: data)
        }
        set {
            defaults.set(try? PropertyListEncoder().encode(newValue), forKey: "cache")
        }
    }

    static var shortDateTime: DateFormatter {
        let dateFormat = DateFormatter()
        dateFormat.locale = NSLocale.current
        dateFormat.dateStyle = .short
        dateFormat.timeStyle = .short
        dateFormat.timeZone = TimeZone.current
        return dateFormat
    }

    static var mediumDateTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone.current
        return formatter
    }

    static var shortTime: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
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

struct FavoriteResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Favorite]
}

struct Pomodoro: Codable {
    let id: Int
    let title: String
    let start: Date
    let end: Date
    let category: String
    let owner: String
}

struct PomodoroResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Pomodoro]
}

func authRequest(username: String, password: String, url: URL, completionHandler: @escaping (HTTPURLResponse, Data) -> Void) {
    var request = URLRequest.init(url: url)

    let loginString = "\(username):\(password)"

    guard let loginData = loginString.data(using: String.Encoding.utf8) else {
        return
    }
    let base64LoginString = loginData.base64EncodedString()

    request.httpMethod = "GET"
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, _ -> Void in
        if let httpResponse = response as? HTTPURLResponse {
            completionHandler(httpResponse, data!)
        }
    })

    task.resume()
}

func postRequest(postBody: Data, method: String, url: URL, completionHandler: @escaping (HTTPURLResponse, Data) -> Void) {
    let username = ApplicationSettings.username!
    let password = ApplicationSettings.password!
    var request = URLRequest(url: url)

    let loginString = "\(username):\(password)"

    guard let loginData = loginString.data(using: String.Encoding.utf8) else {
        return
    }
    let base64LoginString = loginData.base64EncodedString()

    request.httpMethod = method
    request.httpBody = postBody
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, _ -> Void in
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse)
            completionHandler(httpResponse, data!)
        }
    })

    task.resume()
}

func checkLogin(username: String, password: String, completionHandler: @escaping (HTTPURLResponse) -> Void) {

    authRequest(username: username, password: password, url: PomodoroURL.favoriteList(), completionHandler: {response, _ in
        completionHandler(response)
    })
}

func getFavorites(completionHandler: @escaping ([Favorite]) -> Void) {
    authRequest(username: ApplicationSettings.username!, password: ApplicationSettings.password!, url: PomodoroURL.favoriteList(), completionHandler: {_, data in
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let favorites = try decoder.decode(FavoriteResponse.self, from: data)
                completionHandler(favorites.results)
            } catch let error {
                print(error)
            }
        }
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

func updatePomodoro(pomodoro: Pomodoro, completionHandler: @escaping (Pomodoro) -> Void) {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    do {
        let data = try encoder.encode(pomodoro)

        postRequest(postBody: data, method: "PUT", url: PomodoroURL.pomodoroUpdate(pomodoro: pomodoro), completionHandler: {_, data in
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .custom(dateDecode)
                do {
                    let newPomodoro = try decoder.decode(Pomodoro.self, from: data)
                    completionHandler(newPomodoro)
                } catch let error {
                    print(error)
                }
            }
        })
    } catch let error {
        print(error)
    }
}

class PomodoroURL {
    static func pomodoroList() -> URL {
        return URL(string: "\(ApplicationSettings.baseURL)api/pomodoro?limit=100")!
    }

    static func pomodoroUpdate(pomodoro: Pomodoro) -> URL {
        return URL(string: "\(ApplicationSettings.baseURL)api/pomodoro/\(pomodoro.id)")!
    }

    static func favoriteList() -> URL {
        return URL(string: "\(ApplicationSettings.baseURL)api/favorite")!
    }

    static func favoriteStart(favorite: Favorite) -> URL {
        return URL(string: "\(ApplicationSettings.baseURL)api/favorite/\(favorite.id)/start")!
    }
}

class PomodoroAPI {
    static func startFavorite(favorite: Favorite, completionHandler: @escaping (Pomodoro) -> Void) {
        let url = PomodoroURL.favoriteStart(favorite: favorite)
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(favorite)

            postRequest(postBody: data, method: "POST", url: url, completionHandler: {_, data in
                do {
                    print(data)
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .custom(dateDecode)
                    do {
                        let newPomodoro = try decoder.decode(Pomodoro.self, from: data)
                        completionHandler(newPomodoro)
                    } catch let error {
                        print(error)
                    }
                }
            })
        } catch let error {
            print(error)
        }
    }
}

func authedRequest(url: URL, method: String, body: Data?, username: String, password: String, completionHandler: @escaping (HTTPURLResponse, Data) -> Void) {
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

extension Pomodoro {
    init(title: String, category: String, duration: TimeInterval) {
        self.id = 0
        self.owner = ""
        self.title = title
        self.category = category
        self.start = Date()
        self.end = Date.init(timeIntervalSinceNow: duration)
    }

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

    func submit(completionHandler: @escaping (Pomodoro) -> Void) {
        let url = URL(string: "\(ApplicationSettings.baseURL)api/pomodoro")!
        let body = self.encode()
        guard let username = ApplicationSettings.username else { return }
        guard let password = ApplicationSettings.password else { return }

        authedRequest(url: url, method: "POST", body: body, username: username, password: password) { _, data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(dateDecode)
            do {
                let newPomodoro = try decoder.decode(Pomodoro.self, from: data)
                completionHandler(newPomodoro)
            } catch let error {
                print(error)
            }
        }
    }

    func repeat_(completionHandler: @escaping (Pomodoro) -> Void) {
        let start = Date.init()
        let duration = self.end.timeIntervalSince(self.start)
        let end = Date.init(timeInterval: duration, since: start)

        let newPomodoro = Pomodoro(id: 0, title: self.title, start: start, end: end, category: self.category, owner: self.owner)
        newPomodoro.submit(completionHandler: completionHandler)
    }

    func delete(completionHandler: @escaping (Bool) -> Void) {
        let url = URL(string: "\(ApplicationSettings.baseURL)api/pomodoro/\(self.id)")!
        let body = self.encode()
        guard let username = ApplicationSettings.username else { return }
        guard let password = ApplicationSettings.password else { return }

        authedRequest(url: url, method: "DELETE", body: body, username: username, password: password, completionHandler: {_, data  in
            if data != nil {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        })
    }

    static func list(completionHandler: @escaping ([Pomodoro]) -> Void) {
        let url = URL(string: "\(ApplicationSettings.baseURL)api/pomodoro")!
        guard let username = ApplicationSettings.username else { return }
        guard let password = ApplicationSettings.password else { return }

        authedRequest(url: url, method: "GET", body: nil, username: username, password: password, completionHandler: {_, data in
            do {
                let decoder = JSONDecoder()
                // https://stackoverflow.com/a/46538676
                decoder.dateDecodingStrategy = .custom(dateDecode)
                do {
                    let pomodoros = try decoder.decode(PomodoroResponse.self, from: data)
                    completionHandler(pomodoros.results)
                } catch let error {
                    print(error)
                }
            }
        })
    }
}
