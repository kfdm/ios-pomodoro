//
//  HistoryViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

class HistoryCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
}

class HistoryViewController : UITableViewController {
    var data : [Pomodoro] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        getHistory(completionHandler: { pomodoros in
            self.data = pomodoros.sorted(by: { $0.id > $1.id })

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Pomodoro", for: indexPath) as! HistoryCell

        cell.titleLabel.text = data[indexPath.row].title
        cell.categoryLabel.text = data[indexPath.row].category
        cell.durationLabel.text = "\(data[indexPath.row].end)"

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

}
