//
//  SettingsViewController.swift
//  NextPomodoro
//
//  Created by ST20638 on 2018/08/22.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {

    @IBAction func logoutButton(_ sender: UIButton) {
        ApplicationSettings.username = nil
        ApplicationSettings.password = nil
        self.navigationController?.performSegue(withIdentifier: "ShowLogin", sender: self)
    }
}
