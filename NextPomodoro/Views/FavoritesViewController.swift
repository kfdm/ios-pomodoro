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
    var data: [Favorite] = []
    private var logger = OSLog(subsystem: "Favorites", category: "ViewController")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshData()

        tableView.register(FavoriteTableViewCell.self)
    }

    @objc func refreshData() {
        print("Refreshing Favorites")
        Favorite.list(completionHandler: { favorites in
            print("Got New Favorites")
            self.data = favorites.sorted(by: { $0.count > $1.count })

            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
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

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favorite = self.data[indexPath.row]
        let configuration = UISwipeActionsConfiguration(actions: [swipeActionDelete(for: favorite)])
        return configuration
    }

    // MARK: - Buttons

    @IBAction func newFavoriteButton(_ sender: UIBarButtonItem) {
        self.navigationController?.performSegue(withIdentifier: "showNewFavorite", sender: self)
    }

    // MARK: - Swipe Actions

    func swipeActionStart(title: String, color: UIColor, for favorite: Favorite) -> UIContextualAction {
        // TODO: Fix case with already running pomodoro
        let action = UIContextualAction(style: .normal, title: title) { (_, view, completionHandler) in
            os_log("Starting Favorite: %s %s %d", log: Log.favorites, type: .debug, favorite.title, favorite.category, favorite.duration)
            favorite.start { (pomodoro) in
                os_log("Starting Pomodoro: %s %s until %s", log: Log.favorites, type: .debug, pomodoro.title, pomodoro.category, "\(pomodoro.end)")
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

    func swipeActionDelete(for favorite: Favorite) -> UIContextualAction {
        let title = NSLocalizedString("Delete", comment: "Delete Favorite")
        let action = UIContextualAction(style: .destructive, title: title, handler: { (_, _, completionHandler) in
            print("Deleting Favorite \(favorite.title):\(favorite.category):\(favorite.duration)")
            favorite.delete(completionHandler: { _ in
                // TODO: Actually check results
                completionHandler(true)
            })
        })
        action.backgroundColor = Colors.backgroundDestructive
        return action
    }

}
