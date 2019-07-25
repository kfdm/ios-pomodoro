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

    func submit(completionHandler: @escaping (Favorite) -> Void) {
        guard let username = ApplicationSettings.username else { return }
        guard let password = ApplicationSettings.password else { return }

        authedRequest(path: "/api/favorite", method: "POST", body: self.encode(), username: username, password: password) { _, data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(dateDecode)
            do {
                let newFavorite = try decoder.decode(Favorite.self, from: data)
                completionHandler(newFavorite)
            } catch let error {
                print(error)
            }
        }
    }

    func start(completionHandler: @escaping (Pomodoro) -> Void) {
        guard let username = ApplicationSettings.username else { return }
        guard let password = ApplicationSettings.password else { return }

        authedRequest(path: "/api/favorite/\(self.id)/start", method: "POST", body: self.encode(), username: username, password: password) { _, data in
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

    static func list(completionHandler: @escaping ([Favorite]) -> Void) {
        guard let username = ApplicationSettings.username else { return }
        guard let password = ApplicationSettings.password else { return }

        authedRequest(path: "/api/favorite", method: "GET", body: nil, username: username, password: password, completionHandler: {_, data in
            do {
                let decoder = JSONDecoder()
                // https://stackoverflow.com/a/46538676
                decoder.dateDecodingStrategy = .custom(dateDecode)
                do {
                    let pomodoros = try decoder.decode(FavoriteResponse.self, from: data)
                    completionHandler(pomodoros.results)
                } catch let error {
                    print(error)
                }
            }
        })
    }

    func delete(completionHandler: @escaping (Bool) -> Void) {
        guard let username = ApplicationSettings.username else { return }
        guard let password = ApplicationSettings.password else { return }

        authedRequest(path:"/api/favorite/\(self.id)", method: "DELETE", body: self.encode(), username: username, password: password, completionHandler: {_, data  in
                completionHandler(true)
        })
    }
}
