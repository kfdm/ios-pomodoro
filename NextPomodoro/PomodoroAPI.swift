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
        get { return defaults.string(forKey: ApplicationSettingsKeys.baseURL) ?? "https://tsundere.co/"}
        set { defaults.set(newValue, forKey: ApplicationSettingsKeys.baseURL) }
    }

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

func getHistory(completionHandler: @escaping ([Pomodoro]) -> Void) {
    authRequest(username: ApplicationSettings.username!, password: ApplicationSettings.password!, url: PomodoroURL.pomodoroList(), completionHandler: {_, data in
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

func submitPomodoro(title: String, category: String, duration: Int, completionHandler: @escaping (Pomodoro) -> Void) {

    let start = Date.init()
    let end = Date.init(timeIntervalSinceNow: TimeInterval.init(duration))

    let pomodoro = Pomodoro.init(id: 0, title: title, start: start, end: end, category: category, owner: "")
    print(pomodoro)

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    do {
        let data = try encoder.encode(pomodoro)

        postRequest(postBody: data, method: "POST", url: PomodoroURL.pomodoroList(), completionHandler: {_, data in
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
        return URL(string: "\(ApplicationSettings.baseURL)api/pomodoro")!
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

    static func repeatPomodoro(pomodoro: Pomodoro, completionHandler: @escaping (Pomodoro) -> Void) {
        let start = Date.init()
        let duration = pomodoro.end.timeIntervalSince(pomodoro.start)
        let end = Date.init(timeInterval: duration, since: start)

        let newPomodoro = Pomodoro.init(id: 0, title: pomodoro.title, start: start, end: end, category: pomodoro.category, owner: pomodoro.owner)
        print(newPomodoro)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(newPomodoro)

            postRequest(postBody: data, method: "POST", url: PomodoroURL.pomodoroList(), completionHandler: {_, data in
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
}
