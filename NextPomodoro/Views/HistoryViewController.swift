//
//  HistoryViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

class HistoryCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
}

class HistoryViewController: UITableViewController {
    var data: [Pomodoro] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshData()
    }

    @objc func refreshData() {
        print("Refreshing History")
        getHistory(completionHandler: { pomodoros in
            print("Got New History")
            self.data = pomodoros.sorted(by: { $0.id > $1.id })

            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        })
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Pomodoro", for: indexPath) as! HistoryCell

        cell.titleLabel.text = data[indexPath.row].title
        cell.categoryLabel.text = data[indexPath.row].category

        let duration = data[indexPath.row].end.timeIntervalSince(data[indexPath.row].start)
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        cell.durationLabel.text = formatter.string(from: duration)

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let title = NSLocalizedString("Repeat", comment: "Repeat")

        let action = UIContextualAction(style: .normal, title: title, handler: { (_, _, completionHandler) in
//            PomodoroAPI.startFavorite(favorite: self.data[indexPath.row], completionHandler: {  pomodoro in
//                print(pomodoro)
//            })
            print("Re-launch Pomodoro")
            completionHandler(true)
        })

        action.image = UIImage(named: "heart")
        action.backgroundColor = .green
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }

}
