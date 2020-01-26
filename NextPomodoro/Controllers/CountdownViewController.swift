//
//  CountdownViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/08/19.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit
import SwiftMQTT
import os
import SwiftUI

class CountdownViewController: UITableViewController, UITextFieldDelegate, UITabBarDelegate {
    var currentPomodoro: Pomodoro? {
        didSet {
            ApplicationSettings.defaults.set(currentPomodoro, forKey: .cache)
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

    var mqtt: MQTTSession?

    var newTitle = ""
    var newCategory = ""

    // MARK: - custom

    @objc func refreshData() {
        guard ApplicationSettings.defaults.string(forKey: .username) != nil else { return }
        Pomodoro.list(completionHandler: { result in
            switch result {
            case .success(let pomodoros):
                self.currentPomodoro = pomodoros.sorted(by: { $0.id > $1.id }).first
            case .failure(let error):
                os_log(.error, log: .pomodoro, "Error fetching pomodoros: %{public}s", error.localizedDescription)
            }
        })
    }

    // MARK: - lifecycle

    fileprivate func showLogin() {
        let vc = UIHostingController(rootView: LoginView())
        let nav = UINavigationController(rootViewController: vc)
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
        refreshData()

        // Connect and register MQTT Session
        switch MQTTSession.connectionFactory() {
        case .success(let session):
            session.delegate = self
            session.connect(completion: mqttDidConnect(error:))
            mqtt = session
        case .failure(let error):
            print(error)
        }
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
                Pomodoro(title: self.newTitle, category: self.newCategory, minutes: 25).submit { result in
                    switch result {
                    case .success(let newPomodoro):
                        self.currentPomodoro = newPomodoro
                    case .failure(let error):
                        os_log(.error, log: .pomodoro, "Error starting: %{public}s", error.localizedDescription)
                    }
                }
            }
            cell.accessoryType = .none
            return cell
        case [1, 3]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let title = NSLocalizedString("1 hour", comment: "1 hour pomodoro")
            cell.configure(title, style: .default) {
                Pomodoro(title: self.newTitle, category: self.newCategory, minutes: 60).submit { result in
                    switch result {
                    case .success(let newPomodoro):
                        self.currentPomodoro = newPomodoro
                    case .failure(let error):
                        os_log(.error, log: .pomodoro, "Error starting: %{public}s", error.localizedDescription)
                    }
                }
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
                PomodoroRetagRequest(id: id, category: $0).update { result in
                    switch result {
                    case .success(let pomodoro):
                        self.currentPomodoro = pomodoro
                    case .failure(let error):
                        print(error)
                    }
                }
                self.navigationController?.popViewController(animated: true)
            }
            navigationController?.pushViewController(vc, animated: true)
        default:
            os_log("accessoryButtonTappedForRowWith: %@", log: .view, type: .info, indexPath.debugDescription)
        }
    }

    // MARK: - Actions

    func actionExtendTime() {
        guard let pomodoro = currentPomodoro else { return }
        let end = pomodoro.end.addingTimeInterval(TimeInterval(300))
        PomodoroExtendRequest(id: pomodoro.id, end: end).update { result in
            switch result {
            case .success(let pomodoro):
                os_log("Extended pomodoro to %{public}s", log: .pomodoro, type: .debug, pomodoro.end.debugDescription)
                self.currentPomodoro = pomodoro
            case .failure(let error):
                os_log(.error, log: .pomodoro, "Unable to extend time: %{public}s", error.localizedDescription)
            }
        }
    }

    func actionStopEarly() {
        guard let pomodoro = currentPomodoro else { return }
        let end = Date.init()
        PomodoroExtendRequest(id: pomodoro.id, end: end).update { result in
            switch result {
            case .success(let pomodoro):
                os_log("Stopped pomodoro at %{public}s", log: .pomodoro, type: .debug, pomodoro.end.debugDescription)
                self.currentPomodoro = pomodoro
            case .failure(let error):
                os_log(.error, log: .pomodoro, "Failure to extend: %{public}s", error.localizedDescription)
            }
        }
    }
}

extension CountdownViewController: MQTTSessionDelegate {
    func mqttDidDisconnect(session: MQTTSession, error: MQTTSessionError) {
        switch error {
        case .streamError(let e):
            os_log(.error, log: .mqtt, "%{public}s: %{public}s: Reconnecting in 10 seconds. ", error.localizedDescription, e.debugDescription)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                session.connect(completion: self.mqttDidConnect(error:))
            }
        case .socketError:
            os_log(.error, log: .mqtt, "%{public}s: Reconnecting in 10 seconds.", error.description)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                session.connect(completion: self.mqttDidConnect(error:))
            }
        case .connectionError(let response):
            os_log(.error, log: .mqtt, "%{public}s: %{public}s", error.localizedDescription, response.localizedDescription)
        default:
            os_log(.error, log: .mqtt, "%{public}s: Not reconnecting", error.localizedDescription)
        }
    }

    func mqttDidReceive(message: MQTTMessage, from session: MQTTSession) {
        switch message.topic {
        case _ where message.match("^pomodoro/.*/recent$"):
            guard let pomodoro: Pomodoro = Pomodoro.fromData(message.data) else { return }
            self.currentPomodoro = pomodoro
        default:
            os_log(.debug, log: .mqtt, "unknown topic: %@", message.topic)
        }
    }

    func mqttDidAcknowledgePing(from session: MQTTSession) {
        os_log(.debug, log: .mqtt, "Ack")
    }

    func mqttDidConnect(error: MQTTSessionError) {
        switch error {
        case .none:
            guard let mqtt = mqtt else { return }
            guard let username = mqtt.username else { return }
            mqtt.subscribe(to: "pomodoro/\(username)/recent", delivering: .atLeastOnce, completion: self.mqttDidSubscribe)
        default:
            os_log(.error, log: .mqtt, "%{public}s", error.description)
        }
    }

    func mqttDidSubscribe(error: MQTTSessionError) {
        os_log(.error, log: .mqtt, "subscriptionError %{public}s", error.description)
    }
}
