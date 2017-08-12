//
//  ViewController.swift
//  pomodoro
//
//  Created by Paul Traylor on 2017/07/23.
//  Copyright © 2017年 Paul Traylor. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import OnePasswordExtension

class ViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var homeButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var titleView: UINavigationItem!

    @IBAction func goHome(_ sender: UIBarButtonItem) {
        webview.loadRequest(URLRequest(url: URL(string: ApplicationSettings.homeURL)!))
    }

    @IBAction func logoutAction(_ sender: UIBarButtonItem) {
        ApplicationSettings.apiKey = nil
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        webview.loadRequest(URLRequest(url: URL(string: ApplicationSettings.homeURL)!))
    }
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
        OnePasswordExtension.shared().fillItem(intoWebView: self.webview, for: self, sender: sender, showOnlyLogins: false) { (success, error) -> Void in
            if success == false {
                print("Failed to fill into webview: <\(String(describing: error))>")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webview.delegate = self
        shareButton.isEnabled = (false == OnePasswordExtension.shared().isAppExtensionAvailable())
    }

    func updateNavigation(_ title: String) {
        titleView.title = title
        shareButton.isEnabled = ApplicationSettings.apiKey == nil
        logoutButton.isEnabled = ApplicationSettings.apiKey != nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigation("Loading..")
        webview.loadRequest(URLRequest(url: URL(string: ApplicationSettings.homeURL)!))
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        updateNavigation("Loading..")
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        updateNavigation("")
        if ApplicationSettings.apiKey == nil {
            NSLog("Looking up token")
            Alamofire.request(ApplicationSettings.tokenApi, method: .get, parameters: nil, headers: nil)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseData { response in
                    switch response.result {
                    case .success:
                        let json = JSON(data: response.data!)
                        ApplicationSettings.apiKey = json["token"].stringValue
                        NSLog("Setting token \(String(describing: ApplicationSettings.apiKey))")
                        self.updateNavigation("")
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
}
