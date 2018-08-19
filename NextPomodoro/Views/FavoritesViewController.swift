//
//  FavoritesViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

class FavoritesViewController : UITableViewController {
    var data : [Favorite] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        getFavorites(completionHandler: { favorites in
            self.data = favorites.sorted(by: { $0.count > $1.count })

            self.tableView.reloadData()
        })
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Favorite", for: indexPath) as! UITableViewCell

        cell.textLabel?.text = data[indexPath.row].title
        cell.detailTextLabel?.text = "\(data[indexPath.row].category) \(data[indexPath.row].count) "

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

}
