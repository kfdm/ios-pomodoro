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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!

    @IBOutlet weak var startLabel: UITableViewCell!
    @IBOutlet weak var endLabel: UITableViewCell!

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!

    func updateView() {
        if let data = data {
            self.titleLabel.text = data.title
            self.categoryLabel.text = data.category

            self.startLabel.detailTextLabel?.text = data.start
            self.endLabel.detailTextLabel?.text = data.end
        }
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
