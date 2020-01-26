//
//  Info.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation

struct Info: Codable {
    let registrations: Bool
    let mqtt: URL?
}

extension Info {
    static func get(baseURL: String, username: String, password: String, completionHandler handler: @escaping (Result<Info, Error>) -> Void) {
        URLSession.shared.checkLogin(baseURL: baseURL, username: username, password: password) { result in
            handler(result.map({ (data) -> Info in
                return Info.fromData(data)!
            }))
        }
    }
}
