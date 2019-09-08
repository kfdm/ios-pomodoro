//
//  SelectCategoryViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

struct Category {
    let title: String
    let count: Int
}

class SelectCategoryViewController: UITableViewController {
    var categories = [Category]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    var selected: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(LeftTableViewCell.self, forCellReuseIdentifier: "Cell")
        Pomodoro.list { (pomodoros) in
            self.categories = Dictionary(grouping: pomodoros) { $0.category }
                .map { Category(title: $0, count: $1.count) }
                .sorted { $0.count > $1.count }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].title
        cell.detailTextLabel?.text = "\(categories[indexPath.row].count)"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected?(categories[indexPath.row].title)
    }
}
