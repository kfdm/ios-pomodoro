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
    @IBOutlet weak var statusLastPomodoro: NSMenuItem!

    var stopwatch = Timer()
    var reload = Timer()
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        //icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
        statusItem.highlightMode = false

        stopwatch = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateCounter),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(stopwatch, forMode: RunLoopMode.commonModes)
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
                        var lastPomodoro: Pomodoro? = nil
                        for result in json["results"].arrayValue {
                            let pomodoro = Pomodoro(result)
                            if lastPomodoro == nil || pomodoro.end > lastPomodoro!.end {
                                lastPomodoro = pomodoro
                            }
                        }
                        if let pomodoro = lastPomodoro {
                            ApplicationSettings.lastPomodoro = pomodoro
                            self.statusLastPomodoro.title = "\(pomodoro.title) - \(pomodoro.category)"
                        }
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

            let elapsed = Date().timeIntervalSince(pomodoro.end)
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
            
            switch elapsed {
            case 300:
                let notification = NSUserNotification()
                notification.title = "Break Over"
                notification.soundName = NSUserNotificationDefaultSoundName
                NSUserNotificationCenter.default.deliver(notification)
            case 0:
                let notification = NSUserNotification()
                notification.title = "Start Break"
                notification.soundName = NSUserNotificationDefaultSoundName
                NSUserNotificationCenter.default.deliver(notification)
            default:
                break
            }

            statusItem.attributedTitle = NSAttributedString(string: formattedString, attributes:attributes)
        }
    }
    @IBAction func updateClicked(_ sender: Any) {
        fetchPomodoro()
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
