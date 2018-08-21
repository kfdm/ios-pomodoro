//
//  FavoritesViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

class FavoritesCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
}

class FavoritesViewController: UITableViewController {
    var data: [Favorite] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.refreshData()
    }

    @objc func refreshData() {
        print("Refreshing Favorites")
        getFavorites(completionHandler: { favorites in
            print("Got New Favorites")
            self.data = favorites.sorted(by: { $0.count > $1.count })

            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        })
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Favorite", for: indexPath) as! FavoritesCell

        cell.titleLabel.text = data[indexPath.row].title
        cell.categoryLabel.text = data[indexPath.row].category
        cell.durationLabel.text = "\(data[indexPath.row].duration) minutes"
        cell.countLabel.text = "\(data[indexPath.row].count) times"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = self.data[indexPath.row]
        print(favorite)

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let title = NSLocalizedString("Favorite", comment: "Favorite")

        let action = UIContextualAction(style: .normal, title: title, handler: { (_, _, completionHandler) in
//            PomodoroAPI.startFavorite(favorite: self.data[indexPath.row], completionHandler: {  pomodoro in
//                print(pomodoro)
//            })
            print("Start Favorite")
            completionHandler(true)
        })

        action.image = UIImage(named: "heart")
        action.backgroundColor = .green
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
}
