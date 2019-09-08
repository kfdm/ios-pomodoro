//
//  ButtonTableViewCell.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell, ReusableCell {
    typealias Handler = () -> Void
    enum Style {
        case `default`
        case destructive
        case cancel
    }

    @IBOutlet weak var buttonObject: UIButton!
    @IBAction func buttonTriggered(_ sender: UIButton) {
        buttonClick?()
    }

    var buttonClick: Handler?
    var buttonStyle: Style? {
        didSet {
            switch buttonStyle! {
            case .default:
                buttonObject.setTitleColor(.blue, for: .normal)
            default:
                buttonObject.setTitleColor(.red, for: .normal)
            }
        }
    }

    func configure(_ title: String, style: Style, handler: Handler?) {
        let localized = NSLocalizedString(title, comment: "")
        buttonObject.setTitle(localized, for: .normal)
        buttonStyle = style
        buttonClick = handler
    }
}
