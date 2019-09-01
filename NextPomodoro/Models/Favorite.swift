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

    static func decode(from data: Data) -> FavoriteResponse? {
        let decoder = JSONDecoder()
        // https://stackoverflow.com/a/46538676
        decoder.dateDecodingStrategy = .custom(dateDecode)
        do {
            return try decoder.decode(FavoriteResponse.self, from: data)
        } catch let error {
            print(error)
        }
        return nil
    }
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

    static func decode(from data: Data) -> Favorite? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(dateDecode)
        return try? decoder.decode(self, from: data)
    }

    func submit(completionHandler: @escaping (Favorite) -> Void) {
        guard let username = ApplicationSettings.defaults.string(forKey: .username) else { return }
        guard let password = ApplicationSettings.keychain.string(forKey: .server) else { return }

        authedRequest(path: "/api/favorite", method: "POST", body: self.encode(), username: username, password: password) { _, data in
            guard let newFavorite = Favorite.decode(from: data) else { return }
            completionHandler(newFavorite)
        }
    }

    func start(completionHandler: @escaping (Pomodoro) -> Void) {
        guard let username = ApplicationSettings.defaults.string(forKey: .username) else { return }
        guard let password = ApplicationSettings.keychain.string(forKey: .server) else { return }

        authedRequest(path: "/api/favorite/\(self.id)/start", method: "POST", body: self.encode(), username: username, password: password) { _, data in
            guard let newPomodoro = Pomodoro.decode(from: data) else { return }
            completionHandler(newPomodoro)
        }
    }

    static func list(completionHandler: @escaping ([Favorite]) -> Void) {
        guard let username = ApplicationSettings.defaults.string(forKey: .username) else { return }
        guard let password = ApplicationSettings.keychain.string(forKey: .server) else { return }

        authedRequest(path: "/api/favorite", method: "GET", body: nil, username: username, password: password, completionHandler: {_, data in
            guard let response = FavoriteResponse.decode(from: data) else { return }
            completionHandler(response.results)
        })
    }

    func delete(completionHandler: @escaping (Bool) -> Void) {
        guard let username = ApplicationSettings.defaults.string(forKey: .username) else { return }
        guard let password = ApplicationSettings.keychain.string(forKey: .server) else { return }

        authedRequest(path: "/api/favorite/\(self.id)", method: "DELETE", body: self.encode(), username: username, password: password, completionHandler: {_, _  in
                completionHandler(true)
        })
    }
}
