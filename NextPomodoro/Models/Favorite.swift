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
