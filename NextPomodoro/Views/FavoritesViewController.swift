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

        cell.titleLabel.text = data[indexPath.row].title
        cell.categoryLabel.text = data[indexPath.row].category
        cell.durationLabel.text = formatter.string(from: interval)
        cell.countLabel.text = "\(data[indexPath.row].count) times"
        if let icon = data[indexPath.row].icon {
            cell.favoriteIcon.sd_setImage(with: URL(string: icon), placeholderImage: nil, options: SDWebImageOptions.scaleDownLargeImages, completed: nil)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let title = NSLocalizedString("Favorite", comment: "Favorite")

        let action = UIContextualAction(style: .normal, title: title, handler: { (_, _, completionHandler) in
            let favorite = self.data[indexPath.row]
            favorite.start(completionHandler: {  _ in
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

    // MARK: - Buttons

    @IBAction func newFavoriteButton(_ sender: UIBarButtonItem) {
        self.navigationController?.performSegue(withIdentifier: "showNewFavorite", sender: self)
    }

}
