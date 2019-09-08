//
//  CountdownTableViewCell.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/08.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

class CountdownTableViewCell: UITableViewCell, ReusableCell {
    var timer = Timer()

    var countdownDate: Date! {
        didSet {
            timer = Timer.scheduledTimer(
                timeInterval: 1.0,
                target: self,
                selector: #selector(updateCounter),
                userInfo: nil,
                repeats: true
            )
            updateCounter()
        }
    }

    @IBOutlet weak var labelView: UILabel!

    @objc func updateCounter() {
        var elapsed = Date().timeIntervalSince(countdownDate)

        if elapsed > 0 {
            let color = elapsed > 300 ? Colors.latetimer : Colors.breakTimer
            let text = ApplicationSettings.shortTime(elapsed)!
            setCountdown(color: color, text: text)
        } else {
            elapsed *= -1
            let color = Colors.activeTimer
            let text = ApplicationSettings.shortTime(elapsed)!
            setCountdown(color: color, text: text)
        }
    }

    func setCountdown(color: UIColor, text: String) {
        DispatchQueue.main.async {
            self.labelView.backgroundColor = color
            self.labelView.text = text
        }
    }
}
