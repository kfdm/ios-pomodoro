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
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        serverField.becomeFirstResponder()
    }

    func showAlert(for message: String) {

    }

    @IBAction func loginClick(_ sender: UIButton) {
        do {
            let username = try usernameField.validateText([.required])
            let password = try passwordField.validateText([.required])
            let server = try serverField.validateText([.required, .url])

            spinner.startAnimating()
            Info.get(baseURL: server, username: username, password: password) { (info) in
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                }
                ApplicationSettings.defaults.set(value: username, forKey: .username)
                ApplicationSettings.defaults.set(value: server, forKey: .server)
                ApplicationSettings.keychain.set(password, forKey: .server)

                if let mqtt = info.mqtt, let broker = URLComponents(url: mqtt, resolvingAgainstBaseURL: false) {
                    ApplicationSettings.defaults.set(value: broker.host!, forKey: .broker)
                    ApplicationSettings.defaults.set(value: broker.port!, forKey: .brokerPort)
                    ApplicationSettings.defaults.set(value: broker.scheme == "mqtts", forKey: .brokerSSL)
                }

                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    NotificationCenter.default.post(name: .authenticationGranted, object: nil)
                }
            }
        } catch(let error) {
            showAlert(for: (error as! ValidationError).message)
        }
    }
}
