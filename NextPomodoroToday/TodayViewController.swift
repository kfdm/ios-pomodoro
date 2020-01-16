//
//  TodayViewController.swift
//  NextPomodoroToday
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import UIKit
import NotificationCenter
import os

class TodayViewController: UITableViewController, NCWidgetProviding {
    var timer = Timer()
    var currentPomodoro: Pomodoro? {
        didSet {
            updateView()
            updateCounter()
        }
    }

    @IBOutlet weak var titleCell: UITableViewCell!
    @IBOutlet weak var categoryCell: UITableViewCell!
    @IBOutlet weak var countdownCell: UITableViewCell!

    // MARK: - custom

    @objc func updateCounter() {
        guard let pomodoro = currentPomodoro else { return }

        var elapsed = Date().timeIntervalSince(pomodoro.end)

        if elapsed > 0 {
            let color = elapsed > 300 ? Colors.latetimer : Colors.breakTimer
            let text = ApplicationSettings.shortTime(elapsed)!
            setCountdown(color: color, text: text)
        } else {
            elapsed *= -1
            let color = Colors.activeTimer
            let text = ApplicationSettings.shortTime(elapsed)!
            setCountdown(color: color, text: text)
        }

    }

    func updateView() {
        guard let pomodoro = currentPomodoro else { return }
        DispatchQueue.main.async {
            self.titleCell.detailTextLabel?.text = pomodoro.title
            self.categoryCell.detailTextLabel?.text = pomodoro.category
        }
    }

    func setCountdown(color: UIColor, text: String) {
        DispatchQueue.main.async {
            self.countdownCell.detailTextLabel?.text = text
            self.countdownCell.backgroundColor = color
        }
    }

    // MARK: - tableView

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        extensionContext?.open(URL(string: "pomodoro.tsundere.co://")!, completionHandler: nil)
    }

    // MARK: - lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Restore our countdown timer
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateCounter),
            userInfo: nil,
            repeats: true
        )

        // Restore Saved State
        currentPomodoro = ApplicationSettings.defaults.object(forKey: .cache) as? Pomodoro
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        if ApplicationSettings.defaults.string(forKey: .username) == nil {
            completionHandler(NCUpdateResult.failed)
            return
        }
        // Perform any setup necessary in order to update the view.
        DispatchQueue.global(qos: .background).async {
            os_log("Updating widget", log: Log.today, type: .debug)
            Pomodoro.list(completionHandler: { favorites in
                self.currentPomodoro = favorites.sorted(by: { $0.id > $1.id })[0]
                ApplicationSettings.defaults.set(value: self.currentPomodoro, forKey: .cache)
                completionHandler(NCUpdateResult.newData)
            })
        }
    }
}
