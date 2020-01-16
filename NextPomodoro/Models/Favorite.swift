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
    func submit(completionHandler handler: @escaping AuthedRequestResponse) {
        URLSession.shared.authedRequest(path: "/api/favorite", method: .POST, body: self.toData(), completionHandler: handler)
    }

    func start(completionHandler handler: @escaping AuthedRequestResponse) {
        URLSession.shared.authedRequest(path: "/api/favorite/\(self.id)/start", method: .POST, body: self.toData(), completionHandler: handler )
    }

    static func list(completionHandler handler: @escaping AuthedRequestResponse) {
        URLSession.shared.authedRequest(path: "/api/favorite", method: .GET, body: nil, completionHandler: handler)
    }

    func delete(completionHandler handler: @escaping AuthedRequestResponse) {
        URLSession.shared.authedRequest(path: "/api/favorite/\(self.id)", method: .DELETE, body: self.toData(), completionHandler: handler)
    }
}
