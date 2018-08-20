//
//  CountdownViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

class CountdownViewController : UITableViewController {
    var data : Pomodoro?
    var timer = Timer()
    var active = false

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!

    @IBOutlet weak var startLabel: UITableViewCell!
    @IBOutlet weak var endLabel: UITableViewCell!

    @IBOutlet weak var countdownLabel: UITableViewCell!

    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var categoryInput: UITextField!

    func updateView() {
        DispatchQueue.main.async {
            if let data = self.data {
                self.titleLabel.text = data.title
                self.categoryLabel.text = data.category

                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .medium
                formatter.timeZone = TimeZone.current

                self.startLabel.detailTextLabel?.text = formatter.string(for: data.start)
                self.endLabel.detailTextLabel?.text = formatter.string(for: data.end)
            }
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

    @objc func updateCounter() {
        if let data = data {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute, .second]
            formatter.unitsStyle = .positional

            var elapsed = Date().timeIntervalSince(data.end)
            active = elapsed < 0

            if elapsed > 0 {
                setCountdown(color: elapsed > 300 ? UIColor.red : UIColor.yellow, text: formatter.string(from: TimeInterval(elapsed))!)
            } else {
                elapsed *= -1
                setCountdown(color: UIColor.green, text: formatter.string(from: TimeInterval(elapsed))!)
            }
        }
    }

    func setCountdown(color: UIColor, text: String) {
        DispatchQueue.main.async {
            self.countdownLabel.textLabel?.backgroundColor = color
            self.countdownLabel.textLabel?.text = text
        }
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if active {
            if indexPath.section == 2 { return 0 }
            return super.tableView(tableView, heightForRowAt: indexPath)
        } else {
            if indexPath.section == 1 { return 0 }
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if active {
            if section == 2 { return 0.1 }
            return super.tableView(tableView, heightForHeaderInSection: section)
        } else {
            if section == 1 { return 0.1 }
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if active {
            if section == 2 { return 0.1 }
            return super.tableView(tableView, heightForFooterInSection: section)
        } else {
            if section == 1 { return 0.1 }
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        if ApplicationSettings.username != nil {
            getHistory(completionHandler: { favorites in
                self.data = favorites.sorted(by: { $0.id > $1.id })[0]
                self.updateCounter()
                self.updateView()
            })
        }
    }

    @IBAction func extendButton(_ sender: UIButton) {
        print("Extend Pomodoro")
    }

    @IBAction func stopButton(_ sender: UIButton) {
        if let currentPomodoro = self.data {
            let end = Date.init()
            let editPomodoro = Pomodoro.init(id: currentPomodoro.id, title: currentPomodoro.title, start: currentPomodoro.start, end: end, category: currentPomodoro.category, owner: "")
            print("Stopping Pomodoro")
            updatePomodoro(pomodoro: editPomodoro, completionHandler: {  pomodoro in
                print("Stopped?")
                self.data = pomodoro
                self.updateCounter()
                self.updateView()
            })
        } else {
            print("Missing pomodoro?")
        }
    }

    @IBAction func submit25Button(_ sender: UIButton) {
        submitPomodoro(title: titleInput!.text!, category: categoryInput!.text!, duration: 1500, completionHandler: {  pomodoro in
            self.data = pomodoro
            self.updateCounter()
            self.updateView()
        })
    }

    @IBAction func submitHourButton(_ sender: UIButton) {
        submitPomodoro(title: titleInput!.text!, category: categoryInput!.text!, duration: 3600, completionHandler: { pomodoro in
            self.data = pomodoro
            self.updateCounter()
            self.updateView()
        })
    }
}
