//
//  HistoryEditViewController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class HistoryEditViewController: UITableViewController {
    var pomodoro: Pomodoro!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(TextTableViewCell.self)
        tableView.register(ButtonTableViewCell.self)
        tableView.register(SimpleTableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 2
        default:
            fatalError("Unknown section \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath {
        case [0, 0]:
            let cell: TextTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = "Title"
            cell.value = pomodoro.title
            cell.accessoryType = .none
            return cell
        case [0, 1]:
            let cell: TextTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.label = "Category"
            cell.value = pomodoro.category
            cell.accessoryType = .detailButton
            return cell
        case [0, 2]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "Start"
            cell.detailTextLabel?.text = "\(pomodoro.start)"
            cell.accessoryType = .disclosureIndicator
            return cell
        case [0, 3]:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "End"
            cell.detailTextLabel?.text = "\(pomodoro.end)"
            cell.accessoryType = .disclosureIndicator
            return cell

        case [1, 0]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure("Save", color: .blue) {
                print("Save")
            }
            return cell
        case [1, 1]:
            let cell: ButtonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure("Delete", color: .red) {
                print("Delete")
            }
            return cell
        default:
            fatalError("Unknown index \(indexPath)")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [0, 2]:
            print("Click start")
        case [0, 3]:
            print("Click start")
        default:
            print("No selector")
        }
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch indexPath {
        case [0, 1]:
            print("Clicked Category")
        default:
            print("pass")
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
