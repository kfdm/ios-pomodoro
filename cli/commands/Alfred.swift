//
//  Alfred.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/12/19.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import SwiftCLI
import Foundation

struct AlfredIcon: Codable {
    let path: String
}

struct AlfredRow: Codable {
    let arg: String
    let title: String
    let icon: AlfredIcon?
}

extension AlfredRow {
    init (title: String, date: Date, icon: AlfredIcon? = nil) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        self.title = title
        self.arg = formatter.string(from: date)
        self.icon = icon
    }
}

struct AlfredJson: Codable {
    let items: [AlfredRow]
}

extension AlfredJson {
    var json: String {
        let jsonData = try! JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)!
    }
}

class AlfredInstallCommand: Command {
    let name = "install"
    let shortDescription = "Install Alfred support"

    func execute() throws {
        guard let alfred = UserDefaults.init(suiteName: "com.runningwithcrayons.Alfred") else {
            throw CLI.Error(message: "Alfred not found")
        }
    }
}

class AlfredListCommand: Command {
    let name = "list"
    let shortDescription = "Output for Alfred filter workflow"
    func execute() throws {
        var items = [AlfredRow]()

        let semaphore = DispatchSemaphore(value: 0)

        Pomodoro.list { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let pomodoros):
                items.append(contentsOf: pomodoros.results
                    .map {AlfredRow(arg: $0.title, title: $0.title, icon: nil)}
                )
            }

            semaphore.signal()
        }

        semaphore.wait()

        stdout <<< AlfredJson(items: Array(items.prefix(10))).json
    }
}

class AlfredGroup: CommandGroup {
    let name = "alfred"
    let shortDescription = "Support for Alfred"
    let children: [Routable] = [AlfredInstallCommand(), AlfredListCommand()]
}
