//
//  HistoryViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

struct HistoryGroup {
    var date: Date
    var items: [Pomodoro]
}

extension HistoryGroup {
    var title: String {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy"
        return df.string(from: date)
    }
}

class HistoryViewController: UITableViewController {
    var groups = [HistoryGroup]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshData()

        tableView.register(HistoryTableViewCell.self)
    }

    @objc func refreshData() {
        print("Refreshing History")
        Pomodoro.list(completionHandler: { pomodoros in
            print("Got New History")
            let groupedPomodoro = Dictionary.init(grouping: pomodoros) { Calendar.current.startOfDay(for: $0.end) }
            let mappedPomodoro = groupedPomodoro.map({ (date, list) -> HistoryGroup in
                return HistoryGroup(date: date, items: list)
            })

            self.groups = mappedPomodoro.sorted { $0.date > $1.date }

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
        let cell: HistoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.item = pomodoro
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups[section].items.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pomodoro = groups[indexPath.section].items[indexPath.row]

        let title = NSLocalizedString("Repeat", comment: "Repeat existing Pomodoro")
        let repeatAction = UIContextualAction(style: .normal, title: title, handler: { (_, _, completionHandler) in
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

        repeatAction.backgroundColor = UIColor.init(named: "Favorite")

        return UISwipeActionsConfiguration(actions: [repeatAction])
    }
}
