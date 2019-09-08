//
//  HistoryEditViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class HistoryEditViewController: UITableViewController {
    var pomodoro: Pomodoro!
    var updatedPomodoro: ((Pomodoro?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(TextTableViewCell.self)
        tableView.register(ButtonTableViewCell.self)
        tableView.register(LeftTableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 2
        default:
            fatalError("Unknown section \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case [0, 0]:
            let cell: TextTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = "Title"
            cell.value = pomodoro.title
            cell.accessoryType = .none
            cell.selectionStyle = .none
            cell.changed = { self.pomodoro.title = $0  }
            return cell
        case [0, 1]:
            let cell: TextTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = "Category"
            cell.value = pomodoro.category
            cell.accessoryType = .detailButton
            cell.selectionStyle = .none
            cell.changed = { self.pomodoro.category = $0  }
            return cell
        case [0, 2]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "Start"
            cell.detailTextLabel?.text = ApplicationSettings.mediumDate(pomodoro.start)
            cell.accessoryType = .disclosureIndicator
            return cell
        case [0, 3]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "End"
            cell.detailTextLabel?.text = ApplicationSettings.mediumDate(pomodoro.end)
            cell.accessoryType = .disclosureIndicator
            return cell

        case [1, 0]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure("Save", color: .blue) {
                self.pomodoro.update { self.updatedPomodoro?($0) }
            }
            return cell
        case [1, 1]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure("Delete", color: .red) {
                self.pomodoro.delete { _ in self.updatedPomodoro?(nil) }
            }
            return cell
        default:
            fatalError("Unknown index \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 2]:
            print("Click start")
        case [0, 3]:
            print("Click start")
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
            print("pass")
        }
    }
}
