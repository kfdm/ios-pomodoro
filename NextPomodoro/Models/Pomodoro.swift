//
//  Pomodoro.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/09/09.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

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

    static func decode(from data: Data) -> Pomodoro? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(dateDecode)
        return try? decoder.decode(self, from: data)
    }

    func submit(completionHandler: @escaping (Pomodoro) -> Void) {
        guard let username = ApplicationSettings.username else { return }
        guard let password = ApplicationSettings.password else { return }

        authedRequest(path: "/api/pomodoro", method: "POST", body: self.encode(), username: username, password: password) { _, data in
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

    func update(completionHandler: @escaping (Pomodoro) -> Void) {
        guard let username = ApplicationSettings.username else { return }
        guard let password = ApplicationSettings.password else { return }

        authedRequest(path: "/api/pomodoro/\(self.id)", method: "PUT", body: self.encode(), username: username, password: password) { _, data in
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
        guard let username = ApplicationSettings.username else { return }
        guard let password = ApplicationSettings.password else { return }

        authedRequest(path: "/api/pomodoro/\(self.id)", method: "DELETE", body: self.encode(), username: username, password: password, completionHandler: {_, data  in
            // TODO: Handle error
            completionHandler(true)
        })
    }

    static func list(completionHandler: @escaping ([Pomodoro]) -> Void) {
        guard let username = ApplicationSettings.username else { return }
        guard let password = ApplicationSettings.password else { return }

        authedRequest(path: "/api/pomodoro", method: "GET", body: nil, username: username, password: password, completionHandler: {_, data in
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
