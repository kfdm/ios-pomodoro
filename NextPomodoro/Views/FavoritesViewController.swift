//
//  FavoritesViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit
import os.log

class FavoritesViewController: UITableViewController {
    var data: [Favorite] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshData()

        tableView.register(FavoriteTableViewCell.self)
    }

    @objc func refreshData() {
        Favorite.list(completionHandler: { favorites in
            self.data = favorites.sorted(by: { $0.count > $1.count })
        })
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: FavoriteTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.favorite = data[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favorite = self.data[indexPath.row]
        return UISwipeActionsConfiguration(actions: [
            swipeActionStart(title: NSLocalizedString("Start", comment: "Start Favorite"), color: Colors.backgroundFavorite, for: favorite)
        ])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = FavoriteEditViewController(style: .grouped)
        vc.selectedFavorite = data[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Buttons

    @IBAction func newFavoriteButton(_ sender: UIBarButtonItem) {
        self.navigationController?.performSegue(withIdentifier: "showNewFavorite", sender: self)
    }

    // MARK: - Swipe Actions

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // Disable default delete button
        return .none
    }

    func swipeActionStart(title: String, color: UIColor, for favorite: Favorite) -> UIContextualAction {
        // TODO: Fix case with already running pomodoro
        let action = UIContextualAction(style: .normal, title: title) { (_, view, completionHandler) in
            os_log("Starting Favorite: %s %s %d", log: .favorites, type: .debug, favorite.title, favorite.category, favorite.duration)
            favorite.start { (pomodoro) in
                os_log("Starting Pomodoro: %s %s until %s", log: .favorites, type: .debug, pomodoro.title, pomodoro.category, "\(pomodoro.end)")
                if let view = self.tabBarController?.viewControllers?[0] {
                    DispatchQueue.main.async {
                        self.tabBarController?.selectedViewController = view
                        view.viewDidLoad()
                        // TODO: Fix refreshing new Pomodoro
                    }
                }
                completionHandler(true)
            }
        }
        action.backgroundColor = color

        return action
    }
}
