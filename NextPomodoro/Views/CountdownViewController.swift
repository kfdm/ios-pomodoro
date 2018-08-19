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

    func updateView() {
        if let data = data {
            self.titleLabel.text = data.title
            self.categoryLabel.text = data.category

            self.startLabel.detailTextLabel?.text = "\(data.start)"
            self.endLabel.detailTextLabel?.text = "\(data.end)"
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
        getHistory(completionHandler: { favorites in
            self.data = favorites.sorted(by: { $0.id > $1.id })[0]
            print("Updating")
            print(self.data)
            DispatchQueue.main.async {
                self.updateView()
            }
        })
    }
}
