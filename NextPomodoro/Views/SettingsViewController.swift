//
//  SettingsViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(LeftTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(ButtonTableViewCell.self)
    }

    // MARK: - Sections

    fileprivate struct Section {
        let title: String
        let count: Int
    }

    private var sections = [
        Section(title: "Info", count: 1),
        Section(title: "Server", count: 2),
        Section(title: "MQTT", count: 3),
        Section(title: "", count: 1)
    ]

    override func numberOfSections(in tableView: UITableView) -> Int {
       return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    // MARK: - Rows

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case [0, 0]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "Repository"
            cell.detailTextLabel?.text = ApplicationSettings.repository.absoluteString
            cell.accessoryType = .disclosureIndicator
            return cell
        case [1, 0]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "Host"
            cell.detailTextLabel?.text = ApplicationSettings.defaults.string(forKey: .server)
            cell.accessoryType = .disclosureIndicator
            return cell
        case [1, 1]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "User"
            cell.detailTextLabel?.text = ApplicationSettings.defaults.string(forKey: .username)
            cell.accessoryType = .disclosureIndicator
            return cell
        case [2, 0]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "Host"
            cell.detailTextLabel?.text = ApplicationSettings.defaults.string(forKey: .broker)
            return cell
        case [2, 1]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "SSL"
            cell.detailTextLabel?.text = ApplicationSettings.defaults.bool(forKey: .brokerSSL)! ? "YES": "NO"
            return cell
        case [2, 2]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "Port"
            cell.detailTextLabel?.text = ApplicationSettings.defaults.string(forKey: .brokerPort)
            return cell
        case [3, 0]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure("Logout", style: .destructive, handler: actionLogout)
            return cell
        default:
            fatalError("cellForRowAt \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 0]:
            UIApplication.shared.open(ApplicationSettings.repository, options: [:], completionHandler: nil)
        case [1, 0]:
            guard let url = ApplicationSettings.defaults.url(forKey: .server) else { return}
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        default:
            let cell = tableView.cellForRow(at: indexPath)
            cell?.setSelected(true, animated: true)
        }
    }

    // MARK: - Actions

    func actionLogout() {
        ApplicationSettings.deleteLogin()

        let login = LoginViewController.instantiate()
        let nav = UINavigationController(rootViewController: login)
        nav.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(nav, animated: true, completion: nil)
        }
    }
}
