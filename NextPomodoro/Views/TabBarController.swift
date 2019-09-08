//
//  TabBarController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit
import os

class TabBarController: UITabBarController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ApplicationSettings.defaults.string(forKey: .username) == nil {
            self.navigationController?.performSegue(withIdentifier: "ShowLogin", sender: self)
        }
        self.selectedIndex = 0

    }

    func moveToTab(_ index: Int) {
        if let view = self.viewControllers?[index] {
            DispatchQueue.main.async {
                self.selectedViewController = view
            }
        } else {
            os_log("Unable to select tab %d", log: Log.view, type: .error, index)
        }
    }
}
