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

class ViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var homeButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var titleView: UINavigationItem!

    @IBAction func goHome(_ sender: UIBarButtonItem) {
        webview.loadRequest(URLRequest(url: URL(string: "https://tsundere.co/pomodoro")!))
    }

    @IBAction func logoutAction(_ sender: UIBarButtonItem) {
        ApplicationSettings.apiKey = nil
        webview.loadRequest(URLRequest(url: URL(string: "https://tsundere.co/logout")!))
    }
    @IBAction func shareAction(_ sender: UIBarButtonItem) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webview.delegate = self
    }

    func updateNavigation(_ title : String) {
        titleView.title = title
        shareButton.isEnabled = ApplicationSettings.apiKey == nil
        logoutButton.isEnabled = ApplicationSettings.apiKey != nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigation("Loading..")
        webview.loadRequest(URLRequest(url: URL(string: "https://tsundere.co/pomodoro")!))
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
                        NSLog("Setting token \(ApplicationSettings.apiKey)")
                        self.updateNavigation("")
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
}

