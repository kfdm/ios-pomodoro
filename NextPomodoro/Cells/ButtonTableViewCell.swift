//
//  ButtonTableViewCell.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell, ReusableCell {
    @IBOutlet weak var buttonObject: UIButton!
    @IBAction func buttonTriggered(_ sender: UIButton) {
        buttonClick?()
    }

    var buttonClick : (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(_ title: String, color: UIColor, handler: @escaping () -> Void) {
        buttonObject.setTitle(title, for: .normal)
        buttonObject.setTitleColor(color, for: .normal)
        buttonClick = handler
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
