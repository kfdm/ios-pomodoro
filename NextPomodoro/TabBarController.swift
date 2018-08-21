//
//  TabBarController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    override func viewWillAppear(_ animated: Bool) {
        if ApplicationSettings.username == nil {
            self.navigationController?.performSegue(withIdentifier: "ShowLogin", sender: self)
        }
        super.viewWillAppear(animated)
    }
}
