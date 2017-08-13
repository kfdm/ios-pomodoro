//
//  Widget.swift
//  pomodoro
//
//  Created by Paul Traylor on 2017/07/25.
//  Copyright © 2017年 Paul Traylor. All rights reserved.
//

import Foundation
import SwiftyJSON

func jsonDate(_ string: String) -> Date {
    let dateParser = ISO8601DateFormatter()
    dateParser.formatOptions = .withInternetDateTime
    if let date = dateParser.date(from: string) {
        return date
    }
    let split = string.components(separatedBy: ".")
    print("Attemping to parse without milliseconds \(split)")
    if let date = dateParser.date(from: split[0] + "Z") {
        return date
    }
    print("Unable to parse date \(string)")
    return Date()
}

class Pomodoro {
    var id: String
    var title: String
    var category: String
    var end: Date

    init(_ json: JSON) {
        self.id = json["id"].stringValue
        self.title = json["title"].stringValue
        self.category = json["category"].stringValue
        self.end = jsonDate(json["end"].stringValue)
    }

    init(id: String, title: String, category: String, end: Date) {
        self.id = id
        self.title = title
        self.category = category
        self.end = end
    }
}
