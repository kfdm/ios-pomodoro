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

    func start(completionHandler: @escaping (Pomodoro) -> Void) {
        let url = URL(string: "\(ApplicationSettings.baseURL)api/favorite/\(self.id)/start")!
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

    static func list(completionHandler: @escaping ([Favorite]) -> Void) {
        let url = URL(string: "\(ApplicationSettings.baseURL)api/favorite")!
        guard let username = ApplicationSettings.username else { return }
        guard let password = ApplicationSettings.password else { return }

        authedRequest(url: url, method: "GET", body: nil, username: username, password: password, completionHandler: {_, data in
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
}