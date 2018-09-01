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
        self.selectedIndex = 0
        super.viewWillAppear(animated)
    }

    func moveToTab(_ index: Int) {
        if let view = self.viewControllers?[index] {
            DispatchQueue.main.async {
                self.selectedViewController = view
            }
        } else {
            print("Unable to select tab \(index)")
        }
    }

    func logoutAction() -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Logout", comment: "Logout"), style: .destructive, handler: { _ in
            ApplicationSettings.username = nil
            ApplicationSettings.password = nil
            self.navigationController?.performSegue(withIdentifier: "ShowLogin", sender: self)
        })
    }

    func settingsAction() -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Settings", comment: "Settings"), style: .default, handler: { _ in
           UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
        })
    }

    @IBAction func optionsButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)

        // Need to attach this to our tabBar for iPad support
        alert.popoverPresentationController?.barButtonItem = sender
        alert.popoverPresentationController?.sourceView = tabBar

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(settingsAction())
        alert.addAction(logoutAction())
        self.present(alert, animated: true, completion: nil)
    }
}
