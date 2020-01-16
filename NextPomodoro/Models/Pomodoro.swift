//
//  Pomodoro.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/09/09.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation

protocol PomodoroBase: EncodableJson {
    var id: Int { get }
}

extension PomodoroBase {
    func update(completionHandler: @escaping (Pomodoro) -> Void) {
        guard let username = ApplicationSettings.defaults.string(forKey: .username) else { return }
        guard let password = ApplicationSettings.keychain.string(forKey: .server) else { return }

        authedRequest(path: "/api/pomodoro/\(self.id)", method: "PATCH", body: self.encode(), username: username, password: password) { _, data in
            guard let newPomodoro: Pomodoro = Pomodoro.decode(from: data) else { return }
            completionHandler(newPomodoro)
        }
    }
}

struct Pomodoro: EncodableJson {
    let id: Int
    var title: String
    var start: Date
    var end: Date
    var category: String
    let owner: String
    var memo: String?
}

struct PomodoroExtendRequest: PomodoroBase {
    let id: Int
    let end: Date
}

struct PomodoroRetagRequest: PomodoroBase {
    let id: Int
    let category: String
}

struct PomodoroRenameRequest: PomodoroBase {
    let id: Int
    let title: String
}

struct PomodoroResponse: DecodableJson {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Pomodoro]
}

//typealias Handler = (Result<Data, LoadingError>) -> Void
typealias PomodoroListHandler = (Result<PomodoroResponse, Error>) -> Void
typealias PomodoroHandler = (Result<Pomodoro, Error>) -> Void

class DecodingError: Error {

}

extension Pomodoro: PomodoroBase, DecodableJson {
    init(title: String, category: String, minutes: Int) {
        self.id = 0
        self.owner = ""
        self.title = title
        self.category = category
        self.start = Date()
        self.end = Date.init(timeIntervalSinceNow: TimeInterval(minutes * 60))
    }

    func submit(completionHandler: @escaping (Pomodoro) -> Void) {
        guard let username = ApplicationSettings.defaults.string(forKey: .username) else { return }
        guard let password = ApplicationSettings.keychain.string(forKey: .server) else { return }

        authedRequest(path: "/api/pomodoro", method: "POST", body: self.encode(), username: username, password: password) { _, data in
            guard let newPomodoro: Pomodoro = Pomodoro.decode(from: data) else { return }
            completionHandler(newPomodoro)
        }
    }

    func update(completionHandler: @escaping (Pomodoro) -> Void) {
        guard let username = ApplicationSettings.defaults.string(forKey: .username) else { return }
        guard let password = ApplicationSettings.keychain.string(forKey: .server) else { return }

        authedRequest(path: "/api/pomodoro/\(self.id)", method: "PUT", body: self.encode(), username: username, password: password) { _, data in
            guard let newPomodoro: Pomodoro = Pomodoro.decode(from: data) else { return }
            completionHandler(newPomodoro)
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
        guard let username = ApplicationSettings.defaults.string(forKey: .username) else { return }
        guard let password = ApplicationSettings.keychain.string(forKey: .server) else { return }

        authedRequest(path: "/api/pomodoro/\(self.id)", method: "DELETE", body: self.encode(), username: username, password: password, completionHandler: {_, _  in
            // TODO: Handle error
            completionHandler(true)
        })
    }

    static func list(completionHandler: @escaping PomodoroListHandler) {
        let limit = URLQueryItem(name: "limit", value: "100")

        API.shared.authedRequest(path: "/api/pomodoro", method: "GET", queryItems: [limit]) { result in
            switch result {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let data):
                guard let results: PomodoroResponse = PomodoroResponse.decode(from: data) else {
                    completionHandler(.failure(DecodingError()))
                    return
                }
                completionHandler(.success(results))
            }
        }
    }
}
