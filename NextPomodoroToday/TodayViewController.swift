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

    @objc func refreshData() {
        if ApplicationSettings.username != nil {
            getHistory(completionHandler: { favorites in
                self.data = favorites.sorted(by: { $0.id > $1.id })[0]
                self.updateCounter()
                self.updateView()
            })
        }
    }

    @objc func updateCounter() {
        if let data = data {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad

            var elapsed = Date().timeIntervalSince(data.end)

            if elapsed > 0 {
                setCountdown(color: elapsed > 300 ? UIColor(named: "LateTimer")! : UIColor(named: "BreakTimer")!, text: formatter.string(from: TimeInterval(elapsed))!)
            } else {
                elapsed *= -1
                setCountdown(color: UIColor.init(named: "ActiveTimer")!, text: formatter.string(from: TimeInterval(elapsed))!)
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

    // MARK: - lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        refreshData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateCounter),
            userInfo: nil,
            repeats: true
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        refreshData()
        completionHandler(NCUpdateResult.newData)
    }
}
