//
//  Info.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import Foundation

struct Info: DecodableJson {
    let registeration: Bool
    let mqtt: URL?
}

extension Info {
    static func get(baseURL: String, username: String, password: String,  completionHandler handler: @escaping ((Info)->Void)) {
        var request = URLComponents(string: baseURL)!
        request.path = "/api/info"

        authedRequest(url: request, method: "GET", body: nil, username: username, password: password) { (_, data) in
            guard let newInfo: Info = Info.decode(from: data) else { return }
            handler(newInfo)
        }

    }
}
