//
//  TodayViewController.swift
//  widget
//
//  Created by Paul Traylor on 2017/07/23.
//  Copyright © 2017年 Paul Traylor. All rights reserved.
//

import UIKit
import NotificationCenter
import Alamofire
import SwiftyJSON

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var pomodoroLabel: UILabel!
    @IBOutlet weak var pomodoroCountdown: UILabel!

    var lastPomodoro = Date.distantPast
    var lastLabel : String?
    var timer = Timer()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateCounter() {
        self.pomodoroLabel.text = self.lastLabel

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .positional

        var elapsed = Date().timeIntervalSince(self.lastPomodoro)
        if elapsed > 0 {
            let formattedString = formatter.string(from: TimeInterval(elapsed))!
            self.pomodoroCountdown.text = "\(formattedString) ago"
            self.pomodoroCountdown.textColor = elapsed > 300 ? UIColor.red : UIColor.blue
        } else {
            elapsed *= -1
            let formattedString = formatter.string(from: TimeInterval(elapsed))!
            self.pomodoroCountdown.text = "\(formattedString) remaining"
            self.pomodoroCountdown.textColor = UIColor.black
        }
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        NSLog("update widget")
        if let token = ApplicationSettings.apiKey {
            print("make request ")
            let parameters: Parameters = [:]
            let headers = ["Authorization": "Token \(token)"]
            print(headers)
            Alamofire.request(ApplicationSettings.pomodoroAPI, method: .get, parameters: parameters, headers:headers)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseData { response in
                    switch response.result {
                    case .success:
                        let json = JSON(data: response.data!)
                        for result in json["results"].arrayValue {
                            let title = result["title"].stringValue
                            let category = result["title"].stringValue
                            let end = dateFormatter.date(from: result["end"].stringValue)!
                            if end > self.lastPomodoro {
                                self.lastPomodoro = end
                                self.lastLabel = "\(title) - \(category)"
                            }
                        }
                        completionHandler(NCUpdateResult.newData)
                    case .failure(let error):
                        print(error)
                        completionHandler(NCUpdateResult.failed)
                    }
            }
        } else {
            NSLog("No token set. Not logged in ?")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateCounter),
            userInfo: nil,
            repeats: true
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
}
