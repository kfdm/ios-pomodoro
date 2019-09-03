//
//  HistoryTableViewCell.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/03.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell, ReusableCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!

    var item: Pomodoro! {
        didSet {
            titleLabel.text = item.title
            categoryLabel.text = item.category
            durationLabel.text = ApplicationSettings.shortTime(item.start, item.end)
            endLabel.text = ApplicationSettings.mediumDate(item.end)
        }
    }

}
