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

class HistoryViewController: UITableViewController {
    var groups = [String: [Pomodoro]]()
    var sections = [String]()

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
            var newSections = [String]()
            var newGroups = [String: [Pomodoro]]()

            for item in pomodoros {
                let df = DateFormatter()
                df.dateFormat = "MM/dd/yyyy"
                let dateString = df.string(from: item.end)
                if newGroups.index(forKey: dateString) == nil {
                    newGroups[dateString] = [Pomodoro]()
                    newSections.append(dateString)
                }
                newGroups[dateString]?.append(item)
            }

            self.groups = newGroups
            self.sections = newSections.sorted(by: {$0 > $1})

            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        })
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }

    func getPomodoro(indexPath: IndexPath) -> Pomodoro {
        let sec = sections[indexPath.section]
        return groups[sec]![indexPath.row]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pomodoro = getPomodoro(indexPath: indexPath)

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
        let sec = sections[section]
        return groups[sec]!.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let title = NSLocalizedString("Repeat", comment: "Repeat")
        let pomodoro = getPomodoro(indexPath: indexPath)

        let action = UIContextualAction(style: .normal, title: title, handler: { (_, _, completionHandler) in
            print("Re-launch Pomodoro")
            PomodoroAPI.repeatPomodoro(pomodoro: pomodoro, completionHandler: {  _ in
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

        action.image = UIImage(named: "heart")
        action.backgroundColor = UIColor.init(named: "Favorite")
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }

}
