//
//  TodayViewController.swift
//  NextPomodoroToday
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UITableViewController, NCWidgetProviding {
    var data: Pomodoro?
    var timer = Timer()

    @IBOutlet weak var titleCell: UITableViewCell!
    @IBOutlet weak var categoryCell: UITableViewCell!
    @IBOutlet weak var countdownCell: UITableViewCell!

    // MARK: - custom

    @objc func updateCounter() {
        if let data = data {

            var elapsed = Date().timeIntervalSince(data.end)

            if elapsed > 0 {
                let color = elapsed > 300 ? UIColor(named: "LateTimer")! : UIColor(named: "BreakTimer")!
                let text = ApplicationSettings.shortTime(elapsed)!
                setCountdown(color: color, text: text)
            } else {
                elapsed *= -1
                let color = UIColor.init(named: "ActiveTimer")!
                let text = ApplicationSettings.shortTime(elapsed)!
                setCountdown(color: color, text: text)
            }
        }
    }

    func updateView() {
        DispatchQueue.main.async {
            if let data = self.data {
                self.titleCell.detailTextLabel?.text = data.title
                self.categoryCell.detailTextLabel?.text = data.category
            }
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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }

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
        self.data = ApplicationSettings.cache
        self.updateView()
        self.updateCounter()
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
            Pomodoro.list(completionHandler: { favorites in
                self.data = favorites.sorted(by: { $0.id > $1.id })[0]
                self.updateView()
                self.updateCounter()

                // Save state
                ApplicationSettings.cache = self.data

                completionHandler(NCUpdateResult.newData)
            })
        }
    }
}
