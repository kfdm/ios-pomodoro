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
}

struct FavoriteResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Favorite]
}

extension Favorite {
    func submit(completionHandler: @escaping (Favorite) -> Void) {
        URLSession.shared.authedRequest(path: "/api/favorite", method: .POST, body: self.toData()) { _, data in
            guard let newFavorite: Favorite = Favorite.fromData(data) else { return }
            completionHandler(newFavorite)
        }
    }

    func start(completionHandler: @escaping (Pomodoro) -> Void) {
        URLSession.shared.authedRequest(path: "/api/favorite/\(self.id)/start", method: .POST, body: self.toData()) { _, data in
            guard let newPomodoro: Pomodoro = Pomodoro.fromData(data) else { return }
            completionHandler(newPomodoro)
        }
    }

    static func list(completionHandler: @escaping ([Favorite]) -> Void) {
        URLSession.shared.authedRequest(path: "/api/favorite", method: .GET, body: nil, completionHandler: {_, data in
            guard let response: FavoriteResponse = FavoriteResponse.fromData(data) else { return }
            completionHandler(response.results)
        })
    }

    func delete(completionHandler: @escaping (Bool) -> Void) {
        URLSession.shared.authedRequest(path: "/api/favorite/\(self.id)", method: .DELETE, body: self.toData(), completionHandler: {_, _  in
                completionHandler(true)
        })
    }
}
