//
//  FavoritesViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class FavoritesCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var favoriteIcon: UIImageView!
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Favorite", for: indexPath) as! FavoritesCell
        let favorite = data[indexPath.row]

        let interval = TimeInterval(favorite.duration * 60)
        let formatter = ApplicationSettings.shortTime

        cell.titleLabel.text = favorite.title
        cell.categoryLabel.text = favorite.category
        cell.durationLabel.text = formatter.string(from: interval)
        cell.countLabel.text = "\(favorite.count) times"
        if let icon = favorite.icon {
            cell.favoriteIcon.sd_setImage(with: URL(string: icon), placeholderImage: nil, options: SDWebImageOptions.scaleDownLargeImages, completed: nil)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favorite = self.data[indexPath.row]
        let configuration = UISwipeActionsConfiguration(actions: [swipeActionStart(for: favorite)])
        return configuration
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

    func swipeActionStart(for favorite: Favorite) -> UIContextualAction {
        let title = NSLocalizedString("Start", comment: "Start Favorite")
        let action = UIContextualAction(style: .normal, title: title, handler: { (_, _, completionHandler) in
            print("Starting Favorite \(favorite.title):\(favorite.category):\(favorite.duration)")
            favorite.start(completionHandler: {  pomodoro in
                print("Started Pomodoro \(pomodoro.title) \(pomodoro.category) \(pomodoro.end)")
                if let view = self.tabBarController?.viewControllers?[0] {
                    DispatchQueue.main.async {
                        self.tabBarController?.selectedViewController = view
                        view.viewDidLoad()
                        // TODO: Fix refreshing new Pomodoro
                    }
                }
                completionHandler(true)
            })
        })

        action.backgroundColor = UIColor.init(named: "Favorite")

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
        action.backgroundColor = UIColor.init(named: "Destructive")
        return action
    }

}
