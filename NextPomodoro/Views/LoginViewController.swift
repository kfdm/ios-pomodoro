//
//  LoginViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit
import OnePasswordExtension

class LoginViewController: UIViewController {
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    @IBOutlet weak var UsernameField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var OnepasswordButton: UIButton!

    override func viewDidLoad() {
        //self.OnepasswordButton.isHidden = (false == OnePasswordExtension.shared().isAppExtensionAvailable())
        super.viewDidLoad()
    }

    @IBAction func LoginClick(_ sender: UIButton) {
        spinner.startAnimating()
        guard let username = UsernameField.text else { return }
        guard let password = PasswordField.text else { return }

        checkLogin(username: username, password: password, completionHandler: {response in
            if response.statusCode == 200 {
                print("Successfully logged in")
                ApplicationSettings.username = username
                ApplicationSettings.password = password

                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    Router.showMain()
                }
            } else {
                print(response)
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                }
                print("Error logging in")
            }
        })
    }

    @IBAction func OnePasswordClick(_ sender: UIButton) {
        OnePasswordExtension.shared().findLogin(forURLString: ApplicationSettings.baseURL, for: self, sender: sender, completion: { (loginDictionary, error) in
            guard let loginDictionary = loginDictionary else {
                if let error = error as NSError?, error.code != AppExtensionErrorCodeCancelledByUser {
                    print("Error invoking 1Password App Extension for find login: \(String(describing: error))")
                }
                return
            }

            self.UsernameField.text = loginDictionary[AppExtensionUsernameKey] as? String
            self.PasswordField.text = loginDictionary[AppExtensionPasswordKey] as? String
            self.LoginClick(sender)
        })
    }
}
