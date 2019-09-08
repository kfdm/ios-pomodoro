//
//  TextTableViewCell.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell, ReusableCell {
    @IBOutlet private weak var labelField: UILabel!
    @IBOutlet private weak var textField: UITextField!

    var label: String? {
        didSet { labelField.text = label }
    }

    var value: String? {
        didSet { textField.text = value }
    }

    var placeholder: String? {
        didSet { textField.placeholder = placeholder }
    }

    var changed: ((String) -> Void)?

    @objc func textChanged() {
        changed?(textField.text!)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
