//
//  StatusMenuController.swift
//  nagger
//
//  Created by Paul Traylor on 2017/07/29.
//  Copyright © 2017年 Paul Traylor. All rights reserved.
//

import AppKit
import Cocoa
import Alamofire
import SwiftyJSON

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!

    var stopwatch = Timer()
    var reload = Timer()
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        //icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu

        stopwatch = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateCounter),
            userInfo: nil,
            repeats: true
        )
        reload = Timer.scheduledTimer(
            timeInterval: 600.0,
            target: self,
            selector: #selector(fetchPomodoro),
            userInfo: nil,
            repeats: true
        )
        fetchPomodoro()
    }

    func fetchPomodoro() {
        NSLog("update widget")
        if let token = ApplicationSettings.apiKey {
            print("make request ")
            let parameters: Parameters = [:]
            let headers = ["Authorization": "Token \(token)"]
            print(headers)
            Alamofire.request(ApplicationSettings.pomodoroAPI, method: .get, parameters: parameters, headers:headers)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseData { response in
                    switch response.result {
                    case .success:
                        let json = JSON(data: response.data!)
                        var lastPomodoro = ApplicationSettings.lastPomodoro
                        for result in json["results"].arrayValue {
                            let pomodoro = Pomodoro(result)
                            if lastPomodoro == nil || pomodoro.end > lastPomodoro!.end {
                                lastPomodoro = pomodoro
                            }
                        }
                        ApplicationSettings.lastPomodoro = lastPomodoro
                    case .failure(let error):
                        print(error)
                    }
            }
        } else {
            print("defaults write \(ApplicationSettingsKeys.suiteName) PLEASESETME")
        }
    }

    func updateCounter() {
        if let pomodoro = ApplicationSettings.lastPomodoro {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad

            let elapsed = Date().timeIntervalSince(pomodoro.end) * -1
            let formattedString = formatter.string(from: TimeInterval(elapsed))!
            var attributes: [String: Any]?

            switch elapsed {
            case _ where elapsed > 300:
                attributes = [NSForegroundColorAttributeName: NSColor.red ]
            case _ where elapsed < 0:
                attributes = [NSForegroundColorAttributeName: NSColor.black ]
            default:
                attributes = [NSForegroundColorAttributeName: NSColor.blue ]
            }

            statusItem.attributedTitle = NSAttributedString(string: formattedString, attributes:attributes)
        }
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
