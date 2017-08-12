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

class StatusMenuController: NSObject, NSUserNotificationCenterDelegate {
    // MARK: - IBOutlet

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var statusLastPomodoro: NSMenuItem!
    @IBOutlet weak var pauseMenu: NSMenuItem!
    @IBOutlet weak var unpauseMenu: NSMenuItem!

    // MARK: - Vars

    var stopwatch = Timer()
    var reload = Timer()
    var unpauseTimer = Timer()
    let breakDuration = 300 // 5 minutes in seconds
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    // MARK: - Actions

    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")

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
        NSUserNotificationCenter.default.delegate = self

        if let pause = ApplicationSettings.muteUntil {
            if pause < Date() {
                unpause()
            } else {
                pauseUntil(pause)
            }
        }
    }

    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }

    func fetchPomodoro() {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            if let token = ApplicationSettings.apiKey {
                print("Fetching update")
                let parameters: Parameters = [:]
                let headers = ["Authorization": "Token \(token)"]
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
                print("defaults write \(ApplicationSettingsKeys.suiteName) \(ApplicationSettingsKeys.apiKey) PLEASESETME")
            }
        }
    }

    func setTitle(_ title: String, color: NSColor) {
        DispatchQueue.main.async {
            self.statusItem.attributedTitle = NSAttributedString(string: title, attributes:[NSForegroundColorAttributeName: color])
        }
    }

    func updateCounter() {
        if let pomodoro = ApplicationSettings.lastPomodoro {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad

            let elapsed = Int(Date().timeIntervalSince(pomodoro.end))
            let formattedString = formatter.string(from: TimeInterval(elapsed))!

            switch elapsed {
            case _ where elapsed > breakDuration:
                setTitle(formattedString, color: unpauseTimer.isValid ? NSColor.brown : NSColor.red)
            case _ where elapsed < 0:
                setTitle(formattedString, color: NSColor.black)
            default:
                setTitle(formattedString, color: NSColor.blue)
            }

            switch elapsed {
            case breakDuration:
                let notification = NSUserNotification()
                notification.title = "Nag"
                notification.soundName = NSUserNotificationDefaultSoundName
                notification.contentImage = NSImage(named: "Break Over")
                NSUserNotificationCenter.default.deliver(notification)
            case 0:
                let notification = NSUserNotification()
                notification.title = "Break"
                notification.soundName = NSUserNotificationDefaultSoundName
                notification.contentImage = NSImage(named: "Break")
                NSUserNotificationCenter.default.deliver(notification)
            case _ where elapsed % breakDuration == 0:
                // Nag every 5 minutes if not muted
                if elapsed > 0 {
                    if unpauseTimer.isValid {
                        print("Skipping nag because muted")
                    } else {
                        let notification = NSUserNotification()
                        notification.title = "Nag"
                        notification.identifier = "Nag"
                        notification.informativeText = "\(formattedString) since last Pomodoro"
                        notification.soundName = NSUserNotificationDefaultSoundName
                        notification.contentImage = NSImage(named: "Nag")
                        NSUserNotificationCenter.default.deliver(notification)
                    }
                }
            default:
                break
            }
        }
    }
    func pauseUntil(_ date: Date) {
        print("Pausing until \(date)")
        unpauseMenu.isHidden = false
        pauseMenu.isHidden = true
        ApplicationSettings.muteUntil = date

        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let formattedString = formatter.string(from: date)

        unpauseMenu.title = "Paused until \(formattedString)"

        unpauseTimer = Timer(
            fireAt: date,
            interval: 0,
            target: self,
            selector: #selector(unpause),
            userInfo: nil,
            repeats: false
        )
        RunLoop.main.add(unpauseTimer, forMode: .commonModes)
    }

    func unpause() {
        print("Unpaused")
        ApplicationSettings.muteUntil = nil
        pauseMenu.isHidden = false
        unpauseMenu.isHidden = true
        unpauseTimer.invalidate()
    }

    // MARK: - IBActions

    @IBAction func clickedAbout(_ sender: NSMenuItem) {
        let url = URL(string:"https://github.com/kfdm/ios-pomodoro")!
        NSWorkspace.shared().open(url)
    }

    @IBAction func clickedUnpause(_ sender: NSMenuItem) {
        unpause()
    }

    @IBAction func updateClicked(_ sender: Any) {
        fetchPomodoro()
    }

    @IBAction func click15Min(_ sender: NSMenuItem) {
        let pause = Date() + TimeInterval(integerLiteral: 15 * 60)
        pauseUntil(pause)
    }

    @IBAction func click1Hour(_ sender: NSMenuItem) {
        let pause = Date() + TimeInterval(integerLiteral: 60 * 50)
        pauseUntil(pause)
    }

    @IBAction func clickPause(_ sender: NSMenuItem) {
        let date = Date()
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        let pause = cal.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        pauseUntil(pause)
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
