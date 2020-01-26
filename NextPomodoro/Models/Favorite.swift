//
//  Favorite.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/09/09.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation

struct Favorite: Codable {
    let id: Int
    let title: String
    /// Duration in minutes
    let duration: Int
    let category: String
    let owner: String
    let icon: String?
    let count: Int

    struct List: Codable {
        let count: Int
        let next: String?
        let previous: String?
        let results: [Favorite]
    }
}

typealias ResultSingleFavorite = (Result<Favorite, Error>) -> Void
typealias ResultManyFavorite = (Result<[Favorite], Error>) -> Void

extension Favorite {
    func submit(completionHandler handler: @escaping ResultSingleFavorite) {
        URLSession.shared.authedRequest(path: "/api/favorite", method: .POST, body: self.toData(), completionHandler: { result in
            handler(result.map({ (data) -> Favorite in
                return Favorite.fromData(data)!
            }))
        })
    }

    func start(completionHandler handler: @escaping ResultSinglePomodoro) {
        URLSession.shared.authedRequest(path: "/api/favorite/\(self.id)/start", method: .POST, body: self.toData(), completionHandler: { result in
            handler(result.map({ (data) -> Pomodoro in
                return Pomodoro.fromData(data)!
            }))
        })
    }

    static func list(completionHandler handler: @escaping ResultManyFavorite) {
        URLSession.shared.authedRequest(path: "/api/favorite", method: .GET, body: nil, completionHandler: { result in
            handler(result.map({ (data) -> [Favorite] in
                let favorites: Favorite.List = Favorite.List.fromData(data)!
                return favorites.results
            }))
        })
    }

    func delete(completionHandler handler: @escaping AuthedRequestResponse) {
        URLSession.shared.authedRequest(path: "/api/favorite/\(self.id)", method: .DELETE, body: self.toData(), completionHandler: handler)
    }
}
