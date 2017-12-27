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
import CocoaMQTT

class StatusMenuController: NSObject, NSUserNotificationCenterDelegate {
    // MARK: - IBOutlet

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var statusLastPomodoro: NSMenuItem!
    @IBOutlet weak var pauseMenu: NSMenuItem!
    @IBOutlet weak var unpauseMenu: NSMenuItem!
    @IBOutlet weak var stopMenu: NSMenuItem!

    // MARK: - Vars

    var stopwatch = Timer()
    var unpauseTimer = Timer()
    let breakDuration = 300 // 5 minutes in seconds
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    var mqtt: CocoaMQTT?

    // MARK: - Actions
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")

        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: "tsundere.co", port: 1883)
        mqtt?.username = ApplicationSettings.username
        mqtt?.password = ApplicationSettings.password
        mqtt?.keepAlive = 60
        mqtt?.delegate = self
        mqtt?.autoReconnect = true
        mqtt?.connect()

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
        NSUserNotificationCenter.default.delegate = self

        if let pause = ApplicationSettings.muteUntil {
            if pause < Date() {
                unpause()
            } else {
                pauseUntil(pause)
            }
        }
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
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
                self.stopMenu.isHidden = true
            case _ where elapsed < 0:
                setTitle(formattedString, color: NSColor.black)
                self.stopMenu.isHidden = false
            default:
                setTitle(formattedString, color: NSColor.blue)
                self.stopMenu.isHidden = false
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
    @IBAction func stopClicked(_ sender: Any) {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            if let token = ApplicationSettings.apiKey {
                print("Stopping pomodoro")
            }
        }
    }
}

extension StatusMenuController: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        switch ack {
        case .accept:
            mqtt.subscribe("pomodoro/\(mqtt.username!)/recent", qos: CocoaMQTTQOS.qos1)
        default:
            print("didConnectAck: \(ack)，rawValue: \(ack.rawValue)")
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage with message: \(message.string ?? "")")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck with id: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("didReceivedMessage: \(message.string ?? "") with id \(id)")
        if let msg = message.string {
            let json = JSON(parseJSON: msg)
            let pomodoro = Pomodoro(json)
            ApplicationSettings.lastPomodoro = pomodoro
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("didSubscribeTopic to \(topic)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic to \(topic)")
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("didPing")
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        _console("didReceivePong")
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        _console("mqttDidDisconnect")
    }

    func _console(_ info: String) {
        print("Delegate: \(info)")
    }
}
