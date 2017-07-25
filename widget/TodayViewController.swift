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

class TodayViewController: UITableViewController, NCWidgetProviding {
    @IBOutlet weak var pomodoroLabel: UILabel!
    @IBOutlet weak var pomodoroCountdown: UILabel!
    @IBOutlet weak var pomodoroCategory: UILabel!

    var lastPomodoro : Pomodoro?
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view from its nib.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if let pomodoro = lastPomodoro {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Title"
                cell.detailTextLabel?.text = pomodoro.title
            case 1:
                cell.textLabel?.text = "Category"
                cell.detailTextLabel?.text = pomodoro.category
            case 2:
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.day, .hour, .minute, .second]
                formatter.unitsStyle = .positional
                cell.textLabel?.text = "Time"

                var elapsed = Date().timeIntervalSince(pomodoro.end)
                if elapsed > 0 {
                    let formattedString = formatter.string(from: TimeInterval(elapsed))!
                    cell.detailTextLabel?.text = "\(formattedString) ago"
                    cell.detailTextLabel?.textColor = elapsed > 300 ? UIColor.red : UIColor.blue
                } else {
                    elapsed *= -1
                    let formattedString = formatter.string(from: TimeInterval(elapsed))!
                    cell.detailTextLabel?.text = "\(formattedString) remaining"
                    cell.detailTextLabel?.textColor = UIColor.black
                }
            default:
                NSLog("Error?")
            }
        } else {
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
        }
        return cell
    }

    func updateCounter() {
        self.tableView.reloadData()
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
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
                            let pomodoro = Pomodoro(result)
                            if self.lastPomodoro == nil || pomodoro.end > self.lastPomodoro!.end {
                                self.lastPomodoro = pomodoro
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
