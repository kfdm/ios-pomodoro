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
import os

class CountdownViewController: UITableViewController, UITextFieldDelegate, UITabBarDelegate {
    var currentPomodoro: Pomodoro? {
        didSet {
            ApplicationSettings.defaults.cache(currentPomodoro, forKey: .cache)
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }

    var isActivePomodoro: Bool {
        guard let pomodoro = currentPomodoro else { return false }
        return pomodoro.end > Date()
    }

    var mqtt: CocoaMQTT?

    var newTitle = ""
    var newCategory = ""

    // MARK: - custom

    @objc func refreshData() {
        guard ApplicationSettings.defaults.string(forKey: .username) != nil else { return }
        Pomodoro.list(completionHandler: { favorites in
            guard favorites.count > 0 else { return }
            self.currentPomodoro = favorites.sorted(by: { $0.id > $1.id })[0]
        })
    }

    // MARK: - lifecycle

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

        tableView.register(LeftTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(CountdownTableViewCell.self)
        tableView.register(DateTableViewCell.self)
        tableView.register(TextTableViewCell.self)
        tableView.register(ButtonTableViewCell.self)

        currentPomodoro = ApplicationSettings.defaults.object(forKey: .cache)

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
            return isActivePomodoro ? 0: 4
        case 2: // Detail Section
            return isActivePomodoro ? 4: 0
        default:
            fatalError("numberOfRowsInSection \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return isActivePomodoro
                ? ""
                : NSLocalizedString("New Pomodoro", comment: "New Pomodoro header label")
        case 2:
            return isActivePomodoro
                ? NSLocalizedString("Current Pomodoro", comment: "Current Pomodoro header label")
                : ""
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return isActivePomodoro ? 0.1 : 44
        case 2:
            return isActivePomodoro ? 44 : 0.1
        default:
            return 0.1
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
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
            cell.textLabel?.text = NSLocalizedString("Title", comment: "Pomodoro title")
            cell.detailTextLabel?.text = currentPomodoro?.title
            cell.accessoryType = .detailButton
            return cell
        case [0, 1]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Category", comment: "Pomodoro category")
            cell.detailTextLabel?.text = currentPomodoro?.category
            cell.accessoryType = .detailButton
            return cell
        case [0, 2]:
            let cell: CountdownTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.countdownDate = currentPomodoro?.end
            cell.accessoryType = .none
            return cell
        // Register Cells
        case [1, 0]:
            let cell: TextTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = "Title"
            cell.changed = { self.newTitle = $0 }
            cell.accessoryType = .none
            return cell
        case [1, 1]:
            let cell: TextTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = "Category"
            cell.changed = { self.newCategory = $0 }
            cell.accessoryType = .none
            return cell
        case [1, 2]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let title = NSLocalizedString("25 Minutes", comment: "25 minute pomodoro")
            cell.configure(title, style: .default) {
                let newPomodoro = Pomodoro(title: self.newTitle, category: self.newCategory, minutes: 25)
                newPomodoro.submit { self.currentPomodoro = $0 }
            }
            cell.accessoryType = .none
            return cell
        case [1, 3]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let title = NSLocalizedString("1 hour", comment: "1 hour pomodoro")
            cell.configure(title, style: .default) {
                let newPomodoro = Pomodoro(title: self.newTitle, category: self.newCategory, minutes: 60)
                newPomodoro.submit { self.currentPomodoro = $0 }
            }
            cell.accessoryType = .none
            return cell
        // Detail Cells
        case [2, 0]:
            let cell: DateTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = NSLocalizedString("Start Time", comment: "Pomodoro start time")
            cell.value = currentPomodoro?.start
            cell.accessoryType = .none
            return cell
        case [2, 1]:
            let cell: DateTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = NSLocalizedString("End Time", comment: "Pomodoro end time")
            cell.value = currentPomodoro?.end
            cell.accessoryType = .none
            return cell
        case [2, 2]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let title = NSLocalizedString("Add 5 minutes", comment: "Add 5 minutes to existing pomodoro")
            cell.configure(title, style: .default, handler: self.actionExtendTime)
            cell.accessoryType = .none
            return cell
        case [2, 3]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let title = NSLocalizedString("Stop", comment: "Stop existing pomodoro")
            cell.configure(title, style: .destructive, handler: self.actionStopEarly)
            cell.accessoryType = .none
            return cell
        default:
            fatalError("cellForRowAt \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(true, animated: true)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch indexPath {
        case [0, 1]:
            guard let id = currentPomodoro?.id else { return }
            let vc = SelectCategoryViewController(style: .grouped)
            vc.title = NSLocalizedString("Retag Category", comment: "Retag category title")
            vc.selected = {
                let request = PomodoroRetagRequest(id: id, category: $0)
                request.update { self.currentPomodoro = $0 }
                self.navigationController?.popViewController(animated: true)
            }
            navigationController?.pushViewController(vc, animated: true)
        default:
            os_log("accessoryButtonTappedForRowWith: %@", log: Log.view, type: .info, indexPath.debugDescription)
        }
    }

    // MARK: - Actions

    func actionExtendTime() {
        guard let pomodoro = currentPomodoro else { return }
        let end = pomodoro.end.addingTimeInterval(TimeInterval(300))
        let updateRequest = PomodoroExtendRequest(id: pomodoro.id, end: end)

        updateRequest.update(completionHandler: {  pomodoro in
            os_log("Extended pomodoro until", log: Log.pomodoro, type: .debug, pomodoro.end.debugDescription)
            self.currentPomodoro = pomodoro
        })

    }

    func actionStopEarly() {
        guard let pomodoro = currentPomodoro else { return }
        let end = Date.init()
        let updateRequest = PomodoroExtendRequest(id: pomodoro.id, end: end)

        updateRequest.update(completionHandler: {  pomodoro in
            os_log("Stopped pomodoro at", log: Log.pomodoro, type: .debug, pomodoro.end.debugDescription)
            self.currentPomodoro = pomodoro
        })
    }
}

extension CountdownViewController: CocoaMQTTDelegate {
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        os_log("mqttDidPing", log: Log.mqtt, type: .debug)
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        os_log("mqttDidReceivePong", log: Log.mqtt, type: .debug)
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        os_log("mqttDidDisconnect: %@", log: Log.mqtt, type: .error, err.debugDescription)
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        guard let username = mqtt.username else { return }
        mqtt.subscribe("pomodoro/\(username)/recent")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        os_log("didPublishMessage", log: Log.mqtt, type: .debug)
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        os_log("didPublishAck", log: Log.mqtt, type: .debug)
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        switch message.topic {
        case _ where message.match("^pomodoro/.*/recent$"):
            guard let pomodoro: Pomodoro = Pomodoro.decode(from: message.data) else { return }
            self.currentPomodoro = pomodoro
        default:
            os_log("unknown topic: %@", log: Log.mqtt, type: .debug, message.topic)
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        os_log("didSubscribeTopic: %@", log: Log.mqtt, type: .debug, topics)
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        os_log("didUnsubscribeTopic: %@", log: Log.mqtt, type: .debug, topic)
    }

}
