//
//  StatusMenuController.swift
//  nagger
//
//  Created by Paul Traylor on 2017/07/29.
//  Copyright © 2017年 Paul Traylor. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!

    var timer = Timer()
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)

    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        //icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu

        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateCounter),
            userInfo: nil,
            repeats: true
        )
        fetchPomodoro()
    }

    func fetchPomodoro() {
        if let apikey = ApplicationSettings.apiKey {

        } else {
            print("defaults write \(ApplicationSettingsKeys.suiteName) PLEASESETME")
            ApplicationSettings.apiKey = "PLEASE SET ME"
        }
    }

    func updateCounter() {
        if let pomodoro = ApplicationSettings.lastPomodoro {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute, .second]
            formatter.unitsStyle = .positional

            var elapsed = Date().timeIntervalSince(pomodoro.end)
            if elapsed > 0 {
                let formattedString = formatter.string(from: TimeInterval(elapsed))!
                statusItem.title = "\(formattedString) ago"
                //cell.detailTextLabel?.textColor = elapsed > 300 ? UIColor.red : UIColor.blue
            } else {
                elapsed *= -1
                let formattedString = formatter.string(from: TimeInterval(elapsed))!
                statusItem.title = "\(formattedString) remaining"
                //cell.detailTextLabel?.textColor = UIColor.black
            }
        }
    }

    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
