//
//  HistoryEditViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import os

class HistoryEditViewController: UITableViewController {
    var pomodoro: Pomodoro!
    var updatedPomodoro: ((Pomodoro?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(TextTableViewCell.self)
        tableView.register(ButtonTableViewCell.self)
        tableView.register(LeftTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(MarkdownTableViewCell.self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 2
        default:
            fatalError("numberOfRowsInSection \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case [0, 0]:
            let cell: TextTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = NSLocalizedString("Title", comment: "")
            cell.value = pomodoro.title
            cell.accessoryType = .none
            cell.selectionStyle = .none
            cell.changed = { self.pomodoro.title = $0  }
            return cell
        case [0, 1]:
            let cell: TextTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = NSLocalizedString("Category", comment: "")
            cell.value = pomodoro.category
            cell.accessoryType = .detailButton
            cell.selectionStyle = .none
            cell.changed = { self.pomodoro.category = $0  }
            return cell
        case [0, 2]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Start", comment: "")
            cell.detailTextLabel?.text = ApplicationSettings.mediumDate(pomodoro.start)
            cell.accessoryType = .disclosureIndicator
            return cell
        case [0, 3]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("End", comment: "")
            cell.detailTextLabel?.text = ApplicationSettings.mediumDate(pomodoro.end)
            cell.accessoryType = .disclosureIndicator
            return cell
        case [0, 4]:
            let cell: MarkdownTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = NSLocalizedString("Memo", comment: "")
            cell.value = pomodoro.memo
            cell.accessoryType = .none
            return cell

        case [1, 0]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure("Save", style: .default) {
                self.pomodoro.update { self.updatedPomodoro?($0) }
            }
            return cell
        case [1, 1]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure("Delete", style: .destructive) {
                self.pomodoro.delete { _ in self.updatedPomodoro?(nil) }
            }
            return cell
        default:
            fatalError("cellForRowAt \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 2]:
            os_log("Not yet implemented: %s", log: Log.view, type: .default, indexPath.debugDescription)
        case [0, 3]:
            os_log("Not yet implemented: %s", log: Log.view, type: .default, indexPath.debugDescription)
        default:
            let cell = tableView.cellForRow(at: indexPath)
            cell?.setSelected(true, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch indexPath {
        case [0, 1]:
            let vc = SelectCategoryViewController(style: .grouped)
            vc.selected = {
                self.pomodoro.category = $0
                self.navigationController?.popViewController(animated: true)
                tableView.reloadData()
            }
            navigationController?.pushViewController(vc, animated: true)
        default:
            os_log("accessoryButtonTappedForRowWith: %s", log: Log.view, type: .debug, indexPath.debugDescription)
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case [0, 4]:
            return 128
        default:
            return 44
        }
    }
}
