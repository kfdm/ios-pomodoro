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
        }
    }

    @objc func updateCounter() {
        if let data = data {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute, .second]
            formatter.unitsStyle = .positional

            var elapsed = Date().timeIntervalSince(data.end)

            if elapsed > 0 {
                if elapsed > 300 {
                    countdownLabel.textLabel?.backgroundColor = UIColor.red
                } else {
                    countdownLabel.textLabel?.backgroundColor = UIColor.yellow
                }

                countdownLabel.textLabel?.text =  formatter.string(from: TimeInterval(elapsed))!
            } else {
                elapsed *= -1
                countdownLabel.textLabel?.backgroundColor = UIColor.green
                countdownLabel.textLabel?.text =  formatter.string(from: TimeInterval(elapsed))!
            }
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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        if ApplicationSettings.username != nil {
            getHistory(completionHandler: { favorites in
                self.data = favorites.sorted(by: { $0.id > $1.id })[0]
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
                self.updateView()
            })
        } else {
            print("Missing pomodoro?")
        }
    }

    @IBAction func submit25Button(_ sender: UIButton) {
        submitPomodoro(title: titleInput!.text!, category: categoryInput!.text!, duration: 1500, completionHandler: {  pomodoro in
            self.data = pomodoro
            self.updateView()
        })
    }

    @IBAction func submitHourButton(_ sender: UIButton) {
        submitPomodoro(title: titleInput!.text!, category: categoryInput!.text!, duration: 3600, completionHandler: { pomodoro in
            self.data = pomodoro
            self.updateView()
        })
    }
}
