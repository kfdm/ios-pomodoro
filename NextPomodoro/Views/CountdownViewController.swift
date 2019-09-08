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
    var currentPomodoro: Pomodoro? {
        didSet {
            ApplicationSettings.cache = currentPomodoro
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    var active = false {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    var mqtt: CocoaMQTT?

    // MARK: - custom

    @objc func refreshData() {
        guard ApplicationSettings.defaults.string(forKey: .username) != nil else { return }
        Pomodoro.list(completionHandler: { favorites in
            guard favorites.count > 0 else { return }
            self.currentPomodoro = favorites.sorted(by: { $0.id > $1.id })[0]
        })
    }

    // MARK: - lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPomodoro = ApplicationSettings.cache
    }

    func connect() -> CocoaMQTT {
        let clientID = "iosPomodoro-" + String(ProcessInfo().processIdentifier)
        let host = ApplicationSettings.defaults.string(forKey: .broker)!
        let port = ApplicationSettings.defaults.integer(forKey: .brokerPort)
        let mqtt = CocoaMQTT(clientID: clientID, host: host, port: UInt16(port))
        mqtt.enableSSL = ApplicationSettings.defaults.bool(forKey: .brokerSSL)
        mqtt.username = ApplicationSettings.defaults.string(forKey: .username)
        mqtt.password = ApplicationSettings.keychain.string(forKey: .server)
        mqtt.keepAlive = 60
        mqtt.delegate = self
        mqtt.autoReconnect = true
        _ = mqtt.connect()
        return mqtt
    }

    fileprivate func showLogin() {
        let login = LoginViewController.instantiate()
        let nav = UINavigationController(rootViewController: login)
        nav.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(nav, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(SimpleTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(CountdownTableViewCell.self)
        tableView.register(DateTableViewCell.self)
        tableView.register(TextTableViewCell.self)
        tableView.register(ButtonTableViewCell.self)

        tableView.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(completeLogin), name: .authenticationGranted, object: nil)

        if ApplicationSettings.keychain.string(forKey: .server) != nil {
            completeLogin()
        } else {
            showLogin()
        }
    }

    @objc func completeLogin() {
        mqtt = connect()
        refreshData()
    }

    // MARK: - textField

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - tableView

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // Countdown View
            return currentPomodoro == nil ? 0: 3
        case 1: // New Section
            return active ? 0: 4
        case 2: // Detail Section
            return active ? 4: 0
        default:
            fatalError("Unknown section \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case [0, 2]:
            return 128
        default:
            return 44
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        // Countdown Cells
        case [0, 0]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = currentPomodoro?.title
            return cell
        case [0, 1]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = currentPomodoro?.category
            return cell
        case [0, 2]:
            let cell: CountdownTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.countdownDate = currentPomodoro?.end
            cell.activityChanged = { self.active = $0 }
            return cell
        // Register Cells
        case [1, 0]:
            let cell: TextTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = "Title"
            return cell
        case [1, 1]:
            let cell: TextTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = "Category"
            return cell
        case [1, 2]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure("25 Minutes", color: .blue) {
                print("25 min pomodoro")
            }
            return cell
        case [1, 3]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure("1 Hour", color: .blue) {
                print("1 hour pomodoro")
            }
            return cell
        // Detail Cells
        case [2, 0]:
            let cell: DateTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = "Start"
            cell.value = currentPomodoro?.start
            return cell
        case [2, 1]:
            let cell: DateTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = "End"
            cell.value = currentPomodoro?.end
            return cell
        case [2, 2]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure("Add 5 minutes", color: .blue, handler: self.actionExtendTime)
            return cell
        case [2, 3]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure("Stop", color: .red, handler: self.actionStopEarly)
            return cell
        default:
            fatalError("Unknown index \(indexPath)")
        }
    }

    // MARK: - buttons

    func actionExtendTime() {
        guard let pomodoro = currentPomodoro else { return }
        let end = pomodoro.end.addingTimeInterval(TimeInterval(300))
        let updateRequest = PomodoroExtendRequest(id: pomodoro.id, end: end)

        updateRequest.update(completionHandler: {  pomodoro in
            print("Extended pomodoro until \(pomodoro.end)")
            self.currentPomodoro = pomodoro
        })

    }

    func actionStopEarly() {
        guard let pomodoro = currentPomodoro else { return }
        let end = Date.init()
        let updateRequest = PomodoroExtendRequest(id: pomodoro.id, end: end)

        updateRequest.update(completionHandler: {  pomodoro in
            print("Stopped pomodoro at \(pomodoro.end)")
            self.currentPomodoro = pomodoro
        })
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
            guard let pomodoro: Pomodoro = Pomodoro.decode(from: message.data) else { return }
            self.currentPomodoro = pomodoro
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
