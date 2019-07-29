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

class LoginViewController: UIViewController, Storyboarded {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)

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
                ApplicationSettings.defaults.set(username, forKey: .username)
                ApplicationSettings.keychain["server"] = password
                ApplicationSettings.keychain["broker"] = password

                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
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

    }
}
