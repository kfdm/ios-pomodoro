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
    @IBOutlet weak var endLabel: UILabel!
}

struct HistoryGroup {
    var title: String
    var items: [Pomodoro]
}

class HistoryViewController: UITableViewController {
    var groups = [HistoryGroup]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshData()

    }

    @objc func refreshData() {
        print("Refreshing History")
        Pomodoro.list(completionHandler: { pomodoros in
            print("Got New History")
            let df = DateFormatter()
            df.dateFormat = "MM/dd/yyyy"

            let groupedPomodoro = Dictionary.init(grouping: pomodoros) { Calendar.current.startOfDay(for: $0.end) }
            let mappedPomodoro = groupedPomodoro.map({ (date, list) -> HistoryGroup in
                return HistoryGroup(title: df.string(from: date), items: list)
            })

            self.groups = mappedPomodoro

            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        })
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groups[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pomodoro = groups[indexPath.section].items[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "Pomodoro", for: indexPath) as! HistoryCell

        cell.titleLabel.text = pomodoro.title
        cell.categoryLabel.text = pomodoro.category

        let duration = pomodoro.end.timeIntervalSince(pomodoro.start)

        let formatter = ApplicationSettings.shortTime
        cell.durationLabel.text = formatter.string(from: duration)

        let dateFormat = ApplicationSettings.shortDateTime
        cell.endLabel.text = dateFormat.string(from: pomodoro.end)

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].items.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pomodoro = groups[indexPath.section].items[indexPath.row]
        let configuration = UISwipeActionsConfiguration(actions: [swipeActionDelete(for: pomodoro)])
        return configuration
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pomodoro = groups[indexPath.section].items[indexPath.row]
        let configuration = UISwipeActionsConfiguration(actions: [swipeActionRepeat(for: pomodoro)])
        return configuration
    }

    // MARK: - actions

    func swipeActionRepeat(for pomodoro: Pomodoro) -> UIContextualAction {
        let title = NSLocalizedString("Repeat", comment: "Repeat existing Pomodoro")
        let action = UIContextualAction(style: .normal, title: title, handler: { (_, _, completionHandler) in
            pomodoro.repeat_(completionHandler: {  _ in
                print("Move to main view")
                if let view = self.tabBarController?.viewControllers?[0] {
                    DispatchQueue.main.async {
                        self.tabBarController?.selectedViewController = view
                        view.viewDidLoad()
                    }
                }
                completionHandler(true)
            })
        })

        action.backgroundColor = UIColor.init(named: "Favorite")

        return action
    }

    func swipeActionDelete(for pomodoro: Pomodoro) -> UIContextualAction {
        let title = NSLocalizedString("Delete", comment: "Delete History")
        let action = UIContextualAction(style: .destructive, title: title, handler: { (_, _, completionHandler) in
            pomodoro.delete(completionHandler: {result in
                completionHandler(result)
            })
        })
        return action
    }

}
