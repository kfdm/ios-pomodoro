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
    @IBOutlet weak var logoutButton: UIBarButtonItem!

    @IBAction func goHome(_ sender: UIBarButtonItem) {
        webview.loadRequest(URLRequest(url: URL(string: "https://tsundere.co/pomodoro")!))
    }

    @IBAction func logout(_ sender: UIBarButtonItem) {
        ApplicationSettings.apiKey = nil
        webview.loadRequest(URLRequest(url: URL(string: "https://tsundere.co/logout")!))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webview.loadRequest(URLRequest(url: URL(string: "https://tsundere.co/pomodoro")!))
        webview.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
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
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
}

