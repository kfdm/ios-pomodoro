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
    static func get(baseURL: String, username: String, password: String, completionHandler handler: @escaping ((Info) -> Void)) {
        var request = URLComponents()
        request.host = baseURL
        request.path = "/api/info"
        request.scheme = "https"

        authedRequest(url: request, method: "GET", body: nil, username: username, password: password) { (_, data) in
            guard let newInfo: Info = Info.fromData(data) else { return }
            handler(newInfo)
        }

    }
}
