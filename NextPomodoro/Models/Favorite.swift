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
        URLSession.shared.authedRequest(path: "/api/favorite", method: .POST, body: self.toData()) { result in
            switch result {
            case .success(let data):
                guard let newFavorite: Favorite = Favorite.fromData(data) else { return }
                completionHandler(newFavorite)
            case .failure(let error):
                print(error)
            }
        }
    }

    func start(completionHandler: @escaping (Pomodoro) -> Void) {
        URLSession.shared.authedRequest(path: "/api/favorite/\(self.id)/start", method: .POST, body: self.toData()) { result in
            switch result {
            case .success(let data):
                guard let newPomodoro: Pomodoro = Pomodoro.fromData(data) else { return }
                completionHandler(newPomodoro)
            case .failure(let error):
                print(error)
            }
        }
    }

    static func list(completionHandler: @escaping ([Favorite]) -> Void) {
        URLSession.shared.authedRequest(path: "/api/favorite", method: .GET, body: nil, completionHandler: {result in
            switch result {
            case .success(let data):
                guard let response: FavoriteResponse = FavoriteResponse.fromData(data) else { return }
                completionHandler(response.results)
            case .failure(let error):
                print(error)
            }
        })
    }

    func delete(completionHandler: @escaping (Bool) -> Void) {
        URLSession.shared.authedRequest(path: "/api/favorite/\(self.id)", method: .DELETE, body: self.toData(), completionHandler: {_ in
                completionHandler(true)
        })
    }
}
