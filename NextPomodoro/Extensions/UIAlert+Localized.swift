//
//  UIAlert+Localized.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

extension UIAlertAction {
    convenience init(localizedTitle: String, comment: String = "", style newStyle: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) {
        let title = NSLocalizedString(localizedTitle, comment: comment)
        self.init(title: title, style: newStyle, handler: handler)
    }
}
