//
//  CountdownViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit
import CocoaMQTT

class CountdownViewController: UITableViewController, UITextFieldDelegate, UITabBarDelegate {
    var currentPomodoro: Pomodoro?
    var timer = Timer()
    var active = false
    var mqtt: CocoaMQTT?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!

    @IBOutlet weak var startLabel: UITableViewCell!
    @IBOutlet weak var endLabel: UITableViewCell!

    @IBOutlet weak var countdownLabel: UITableViewCell!

    @IBOutlet weak var titleInput: UITextField!
    @IBOutlet weak var categoryInput: UITextField!

    // MARK: - custom

    func updateView() {
        guard let pomodoro = currentPomodoro else { return }
        let formatter = ApplicationSettings.mediumDateTime

        DispatchQueue.main.async {
            self.titleLabel.text = pomodoro.title
            self.categoryLabel.text = pomodoro.category

            self.startLabel.detailTextLabel?.text = formatter.string(for: pomodoro.start)
            self.endLabel.detailTextLabel?.text = formatter.string(for: pomodoro.end)

            self.tableView.refreshControl?.endRefreshing()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

    @objc func updateCounter() {
        guard let data = currentPomodoro else { return }
        let formatter = ApplicationSettings.shortTime

        var elapsed = Date().timeIntervalSince(data.end)
        active = elapsed < 0

        if elapsed > 0 {
            setCountdown(color: elapsed > 300 ? UIColor(named: "LateTimer")! : UIColor(named: "BreakTimer")!, text: formatter.string(from: TimeInterval(elapsed))!)
        } else {
            elapsed *= -1
            setCountdown(color: UIColor.init(named: "ActiveTimer")!, text: formatter.string(from: TimeInterval(elapsed))!)
        }
    }

    func setCountdown(color: UIColor, text: String) {
        DispatchQueue.main.async {
            self.countdownLabel.textLabel?.backgroundColor = color
            self.countdownLabel.textLabel?.text = text
        }
    }

    @objc func refreshData() {
        guard ApplicationSettings.defaults.string(forKey: .username) != nil else { return }
        Pomodoro.list(completionHandler: { favorites in
            guard favorites.count > 0 else { return }
            self.currentPomodoro = favorites.sorted(by: { $0.id > $1.id })[0]
            self.updateCounter()
            self.updateView()
        })
    }

    // MARK: - lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateCounter),
            userInfo: nil,
            repeats: true
        )
        currentPomodoro = ApplicationSettings.cache
    }

    func connect() -> CocoaMQTT {
        let clientID = "iosPomodoro-" + String(ProcessInfo().processIdentifier)
        let mqtt = CocoaMQTT(clientID: clientID, host: "chiharu.kungfudiscomonkey.net", port: 8883)
        mqtt.enableSSL = true
        mqtt.username = ApplicationSettings.defaults.string(forKey: .username)
        mqtt.password = ApplicationSettings.keychain["broker"]
        mqtt.keepAlive = 60
        mqtt.delegate = self
        mqtt.autoReconnect = true
        _ = mqtt.connect()
        return mqtt
    }

    fileprivate func showLogin() {
        let login = LoginViewController.instantiate()
        let nav = UINavigationController(rootViewController: login)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        titleInput.delegate = self
        categoryInput.delegate = self

        if ApplicationSettings.defaults.string(forKey: .username) != nil {
            mqtt = connect()
            refreshData()
        } else {
            showLogin()
        }
    }

    // MARK: - textField

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - tableView

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: // Countdown Timer
            if self.currentPomodoro == nil { return 0 }
            return super.tableView(tableView, heightForRowAt: indexPath)
        case 1: // Stop Timer
            if self.currentPomodoro == nil { return 0 }
            return active ? super.tableView(tableView, heightForRowAt: indexPath) : 0
        case 2: // New Timer
            return active ? 0 : super.tableView(tableView, heightForRowAt: indexPath)
        default:
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: // Countdown Timer
            if self.currentPomodoro == nil { return 0.1 }
            return super.tableView(tableView, heightForHeaderInSection: section)
        case 1: // Stop Timer
            if self.currentPomodoro == nil { return 0.1 }
            return active ? super.tableView(tableView, heightForHeaderInSection: section) : 0.1
        case 2: // New Timer
            return active ? 0.1 : super.tableView(tableView, heightForHeaderInSection: section)
        default:
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0: // Countdown Timer
            if self.currentPomodoro == nil { return 0.1 }
            return super.tableView(tableView, heightForFooterInSection: section)
        case 1: // Stop Timer
            if self.currentPomodoro == nil { return 0.1 }
            return active ? super.tableView(tableView, heightForFooterInSection: section) : 0.1
        case 2: // New Timer
            return active ? 0.1 : super.tableView(tableView, heightForFooterInSection: section)
        default:
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }

    // MARK: - buttons

    @IBAction func extendButton(_ sender: UIButton) {
        if let currentPomodoro = self.currentPomodoro {
            let end = currentPomodoro.end.addingTimeInterval(TimeInterval(300))
            let editPomodoro = Pomodoro.init(id: currentPomodoro.id, title: currentPomodoro.title, start: currentPomodoro.start, end: end, category: currentPomodoro.category, owner: "")

            print("Extend Pomodoro until \(editPomodoro.end)")
            editPomodoro.update(completionHandler: {  pomodoro in
                print("Extended pomodoro until \(pomodoro.end)")
                self.currentPomodoro = pomodoro
                self.updateCounter()
                self.updateView()
            })
        } else {
            print("Missing pomodoro?")
        }
    }

    @IBAction func stopButton(_ sender: UIButton) {
        if let currentPomodoro = self.currentPomodoro {
            let end = Date.init()
            let editPomodoro = Pomodoro.init(id: currentPomodoro.id, title: currentPomodoro.title, start: currentPomodoro.start, end: end, category: currentPomodoro.category, owner: "")

            print("Stopping Pomodoro")
            editPomodoro.update(completionHandler: {  pomodoro in
                print("Stopped Pomodoro at \(pomodoro.end)")
                self.currentPomodoro = pomodoro
                self.updateCounter()
                self.updateView()
            })
        } else {
            print("Missing pomodoro?")
        }
    }

    @IBAction func submit25Button(_ sender: UIButton) {
        titleInput.resignFirstResponder()
        categoryInput.resignFirstResponder()

        guard let title = titleInput.text else { return }
        guard let category = categoryInput.text else { return }
        let duration = TimeInterval(1500)

        let pomodoro = Pomodoro(title: title, category: category, duration: duration)

        pomodoro.submit { pomodoro in
            self.currentPomodoro = pomodoro
            self.updateCounter()
            self.updateView()
        }
    }

    @IBAction func submitHourButton(_ sender: UIButton) {
        titleInput.resignFirstResponder()
        categoryInput.resignFirstResponder()

        guard let title = titleInput.text else { return }
        guard let category = categoryInput.text else { return }
        let duration = TimeInterval(3600)

        let pomodoro = Pomodoro(title: title, category: category, duration: duration)

        pomodoro.submit { pomodoro in
            self.currentPomodoro = pomodoro
            self.updateCounter()
            self.updateView()
        }
    }
    @IBAction func submitOptionsButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)

        // Need to attach this to our tabBar for iPad support
        alert.popoverPresentationController?.barButtonItem = sender
        //alert.popoverPresentationController?.sourceView = tabBar

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(settingsAction())
        alert.addAction(logoutAction())
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Actions

    func logoutAction() -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Logout", comment: "Logout"), style: .destructive, handler: { _ in
            ApplicationSettings.deleteLogin()
            self.showLogin()
        })
    }

    func settingsAction() -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Settings", comment: "Settings"), style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        })
    }
}

extension CountdownViewController: CocoaMQTTDelegate {
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("didPing")
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("didPong")
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("didDisconnect")
        print(err.debugDescription)
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        guard let username = mqtt.username else { return }
        mqtt.subscribe("pomodoro/\(username)/recent")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        switch message.topic {
        case _ where message.match("^pomodoro/.*/recent$"):
            guard let pomodoro = Pomodoro.decode(from: message.data) else { return }
            self.currentPomodoro = pomodoro
            self.updateView()
        default:
            print("Unknown topic \(message.topic)")
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        print("didSubscribeTopic \(topics)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic")
    }

}
