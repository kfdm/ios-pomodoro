//
//  MarkdownTableViewCell.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/10/12.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class MarkdownTableViewCell: UITableViewCell, ReusableCell, UITextFieldDelegate {
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var textField: UITextView!

    var label: String? {
        didSet {
            labelView.text = label
        }
    }

    var value: String? {
        didSet {
            textField.text = value
        }
    }

    var changed: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
//        textField.delegate = self as! UITextViewDelegate
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        changed?(textField.text!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            textField.becomeFirstResponder()
        }
    }

}
