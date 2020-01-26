//
//  Pomodoro.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/09/09.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

protocol PomodoroBase: Codable {
    var id: Int { get }
}

extension PomodoroBase {
    func update(completionHandler: @escaping ResultSinglePomodoro) {
        URLSession.shared.authedRequest(path: "/api/pomodoro/\(self.id)", method: .PATCH, body: self.toData(), queryItems: nil, completionHandler: { result in
            completionHandler( result.map { (data) -> Pomodoro in
                return Pomodoro.fromData(data)!
            })
        })
    }
}

struct Pomodoro: Codable {
    let id: Int
    var title: String
    var start: Date
    var end: Date
    var category: String
    let owner: String
    var memo: String?

    struct List: Codable {
        let count: Int
        let next: String?
        let previous: String?
        let results: [Pomodoro]
    }
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

typealias ResultSinglePomodoro = (Result<Pomodoro, Error>) -> Void
typealias ResultManyPomodoro = (Result<[Pomodoro], Error>) -> Void

extension Pomodoro: PomodoroBase {
    init(title: String, category: String, minutes: Int) {
        self.id = 0
        self.owner = ""
        self.title = title
        self.category = category
        self.start = Date()
        self.end = Date.init(timeIntervalSinceNow: TimeInterval(minutes * 60))
    }

    func submit(completionHandler handler: @escaping ResultSinglePomodoro) {
        URLSession.shared.authedRequest(path: "/api/pomodoro", method: .POST, body: self.toData(), completionHandler: { response in
            handler(response.map({ (data) -> Pomodoro in
                return Pomodoro.fromData(data)!
            }))
        })
    }

    func update(completionHandler handler: @escaping ResultSinglePomodoro) {
        URLSession.shared.authedRequest(path: "/api/pomodoro", method: .PUT, body: self.toData(), completionHandler: { response in
            handler(response.map({ (data) -> Pomodoro in
                return Pomodoro.fromData(data)!
            }))
        })
    }

    func repeat_(completionHandler handler: @escaping ResultSinglePomodoro) {
        let start = Date.init()
        let duration = self.end.timeIntervalSince(self.start)
        let end = Date.init(timeInterval: duration, since: start)

        let newPomodoro = Pomodoro(id: 0, title: self.title, start: start, end: end, category: self.category, owner: self.owner)
        newPomodoro.submit(completionHandler: handler)
    }

    func delete(completionHandler handler: @escaping (Bool) -> Void) {
        URLSession.shared.authedRequest(path: "/api/pomodoro/\(self.id)", method: .DELETE, body: self.toData(), completionHandler: {_  in
            // TODO: Handle error
            handler(true)
        })
    }

    static func list(completionHandler handler: @escaping ResultManyPomodoro) {
        let limit = URLQueryItem(name: "limit", value: "100")
        URLSession.shared.authedRequest(path: "/api/pomodoro", method: .GET, body: nil, queryItems: [limit]) { response in
            handler(response.map({ (data) -> [Pomodoro] in
                let results: Pomodoro.List = Pomodoro.List.fromData(data)!
                return results.results
            })
            )
        }
    }
}
