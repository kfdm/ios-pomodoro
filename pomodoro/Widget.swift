//
//  Widget.swift
//  pomodoro
//
//  Created by Paul Traylor on 2017/07/25.
//  Copyright © 2017年 Paul Traylor. All rights reserved.
//

import Foundation
import SwiftyJSON

class Pomodoro {
    var id: String
    var title: String
    var category: String
    var end: Date

    init(_ json: JSON) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        self.id = json["id"].stringValue
        self.title = json["title"].stringValue
        self.category = json["category"].stringValue
        self.end = dateFormatter.date(from: json["end"].stringValue)!
    }
}
