//
//  DateTableViewCell.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class DateTableViewCell: UITableViewCell, ReusableCell {
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var valueView: UILabel!

    var label: String? {
        didSet { labelView.text = label }
    }
    var value: Date? {
        didSet {
            valueView.text = ApplicationSettings.mediumDate(value!)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
