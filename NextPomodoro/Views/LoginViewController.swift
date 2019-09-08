//
//  LoginViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UITableViewController, Storyboarded {
    var spinner = UIActivityIndicatorView(style: .whiteLarge)

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var serverField: UITextField!
    @IBOutlet weak var brokerField: UITextField!
    @IBOutlet weak var brokerPort: UITextField!
    @IBOutlet weak var brokerSSL: UISwitch!

    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func editingEnded(_ sender: UITextField) {
        loginButton.isEnabled = [
            usernameField.text,
            passwordField.text,
            serverField.text,
            brokerField.text,
            brokerPort.text
            ].allSatisfy { $0 != "" }
    }

    @IBAction func toggleSSL(_ sender: UISwitch) {
        brokerPort.text = sender.isOn ? "8883" : "1883"
    }

    @IBAction func loginClick(_ sender: UIButton) {
        spinner.startAnimating()
        checkLogin(baseURL: serverField.text!, username: usernameField.text!, password: passwordField.text!) { (response) in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                ApplicationSettings.defaults.set(self.usernameField.text!, forKey: .username)
                ApplicationSettings.defaults.set(self.serverField.text!, forKey: .server)
                ApplicationSettings.defaults.set(self.brokerField.text!, forKey: .broker)
                ApplicationSettings.defaults.set(Int(self.brokerPort.text!), forKey: .brokerPort)
                ApplicationSettings.defaults.set(self.brokerSSL.isOn, forKey: .brokerSSL)

                ApplicationSettings.keychain.set(response.url!.absoluteString, forKey: .server)
                self.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: .authenticationGranted, object: nil)
            }
        }
    }
}
