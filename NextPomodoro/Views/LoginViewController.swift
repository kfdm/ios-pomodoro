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
    @IBOutlet weak var UsernameField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var OnepasswordButton: UIButton!


    override func viewDidLoad() {
        //self.OnepasswordButton.isHidden = (false == OnePasswordExtension.shared().isAppExtensionAvailable())
        super.viewDidLoad()
    }

    @IBAction func LoginClick(_ sender: UIButton) {
        checkLogin(username: UsernameField.text!, password: PasswordField.text!, completionHandler: {response in
            if response.statusCode == 200 {
                print("Successfully logged in")
                ApplicationSettings.username = self.UsernameField.text!
                ApplicationSettings.password = self.PasswordField.text!
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }

            } else {
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