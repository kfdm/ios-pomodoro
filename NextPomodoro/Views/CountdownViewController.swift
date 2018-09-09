//
//  CountdownViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

class CountdownViewController: UITableViewController, UITextFieldDelegate {
    var data: Pomodoro?
    var timer = Timer()
    var active = false

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!

    @IBOutlet weak var startLabel: UITableViewCell!
    @IBOutlet weak var endLabel: UITableViewCell!

    @IBOutlet weak var countdownLabel: UITableViewCell!

    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var categoryInput: UITextField!

    // MARK: - custom

    func updateView() {
        DispatchQueue.main.async {
            if let data = self.data {
                self.titleLabel.text = data.title
                self.categoryLabel.text = data.category

                let formatter = ApplicationSettings.mediumDateTime

                self.startLabel.detailTextLabel?.text = formatter.string(for: data.start)
                self.endLabel.detailTextLabel?.text = formatter.string(for: data.end)
            }
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

    @objc func updateCounter() {
        if let data = data {
            let formatter = ApplicationSettings.shortTime

            var elapsed = Date().timeIntervalSince(data.end)
            active = elapsed < 0

            if elapsed > 0 {
                setCountdown(color: elapsed > 300 ? UIColor(named: "LateTimer")! : UIColor(named: "BreakTimer")!, text: formatter.string(from: TimeInterval(elapsed))!)
            } else {
                elapsed *= -1
                setCountdown(color: UIColor.init(named: "ActiveTimer")!, text: formatter.string(from: TimeInterval(elapsed))!)
            }
        }
    }

    func setCountdown(color: UIColor, text: String) {
        DispatchQueue.main.async {
            self.countdownLabel.textLabel?.backgroundColor = color
            self.countdownLabel.textLabel?.text = text
        }
    }

    @objc func refreshData() {
        if ApplicationSettings.username != nil {
            Pomodoro.list(completionHandler: { favorites in
                guard favorites.count > 0 else { return }
                self.data = favorites.sorted(by: { $0.id > $1.id })[0]
                self.updateCounter()
                self.updateView()
            })
        }
    }

    // MARK: - lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateCounter),
            userInfo: nil,
            repeats: true
        )
        data = ApplicationSettings.cache
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        titleInput.delegate = self
        categoryInput.delegate = self
        refreshData()

    }

    // MARK: - textField

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - tableView

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: // Countdown Timer
            if self.data == nil { return 0 }
            return super.tableView(tableView, heightForRowAt: indexPath)
        case 1: // Stop Timer
            if self.data == nil { return 0 }
            return active ? super.tableView(tableView, heightForRowAt: indexPath) : 0
        case 2: // New Timer
            return active ? 0 : super.tableView(tableView, heightForRowAt: indexPath)
        default:
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: // Countdown Timer
            if self.data == nil { return 0.1 }
            return super.tableView(tableView, heightForHeaderInSection: section)
        case 1: // Stop Timer
            if self.data == nil { return 0.1 }
            return active ? super.tableView(tableView, heightForHeaderInSection: section) : 0.1
        case 2: // New Timer
            return active ? 0.1 : super.tableView(tableView, heightForHeaderInSection: section)
        default:
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0: // Countdown Timer
            if self.data == nil { return 0.1 }
            return super.tableView(tableView, heightForFooterInSection: section)
        case 1: // Stop Timer
            if self.data == nil { return 0.1 }
            return active ? super.tableView(tableView, heightForFooterInSection: section) : 0.1
        case 2: // New Timer
            return active ? 0.1 : super.tableView(tableView, heightForFooterInSection: section)
        default:
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }

    // MARK: - buttons

    @IBAction func extendButton(_ sender: UIButton) {
        if let currentPomodoro = self.data {
            let end = currentPomodoro.end.addingTimeInterval(TimeInterval(300))
            let editPomodoro = Pomodoro.init(id: currentPomodoro.id, title: currentPomodoro.title, start: currentPomodoro.start, end: end, category: currentPomodoro.category, owner: "")

            print("Extend Pomodoro until \(editPomodoro.end)")
            editPomodoro.update(completionHandler: {  pomodoro in
                print("Extended pomodoro until \(pomodoro.end)")
                self.data = pomodoro
                self.updateCounter()
                self.updateView()
            })
        } else {
            print("Missing pomodoro?")
        }
    }

    @IBAction func stopButton(_ sender: UIButton) {
        if let currentPomodoro = self.data {
            let end = Date.init()
            let editPomodoro = Pomodoro.init(id: currentPomodoro.id, title: currentPomodoro.title, start: currentPomodoro.start, end: end, category: currentPomodoro.category, owner: "")

            print("Stopping Pomodoro")
            editPomodoro.update(completionHandler: {  pomodoro in
                print("Stopped Pomodoro at \(pomodoro.end)")
                self.data = pomodoro
                self.updateCounter()
                self.updateView()
            })
        } else {
            print("Missing pomodoro?")
        }
    }

    @IBAction func submit25Button(_ sender: UIButton) {
        titleInput.resignFirstResponder()
        categoryInput.resignFirstResponder()

        guard let title = titleInput.text else { return }
        guard let category = categoryInput.text else { return }
        let duration = TimeInterval(1500)

        let pomodoro = Pomodoro(title: title, category: category, duration: duration)

        pomodoro.submit { pomodoro in
            self.data = pomodoro
            self.updateCounter()
            self.updateView()
        }
    }

    @IBAction func submitHourButton(_ sender: UIButton) {
        titleInput.resignFirstResponder()
        categoryInput.resignFirstResponder()

        guard let title = titleInput.text else { return }
        guard let category = categoryInput.text else { return }
        let duration = TimeInterval(3600)

        let pomodoro = Pomodoro(title: title, category: category, duration: duration)

        pomodoro.submit { pomodoro in
            self.data = pomodoro
            self.updateCounter()
            self.updateView()
        }
    }
}
