//
//  NewFavoriteController.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2018/09/09.
//  Copyright © 2018年 Paul Traylor. All rights reserved.
//

import Foundation
import UIKit

class NewFavoriteController: UIViewController {
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var categoryText: UITextField!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!

    @IBAction func durationChanged(_ sender: UISlider) {
        let duration = TimeInterval(sender.value.rounded(.down) * 60)
        DispatchQueue.main.async {
            self.durationLabel.text = ApplicationSettings.shortTime(duration)
        }
    }

    @IBAction func submitNewFavorite(_ sender: UIButton) {
        guard let title = titleText.text else { return }
        guard let category = categoryText.text else { return }
        let duration = Int(durationSlider.value)

        let favorite = Favorite.init(id: 0, title: title, duration: duration, category: category, owner: "", icon: nil, count: 0)

        favorite.submit(completionHandler: {favorite in
            print(favorite)
           self.navigationController?.popToRootViewController(animated: true)
        })
    }

    @IBAction func setFiveMin(_ sender: UIButton) {
        self.durationSlider.value = 5
        durationChanged(self.durationSlider)
    }

    @IBAction func setThirtyMinute(_ sender: UIButton) {
        self.durationSlider.value = 30
        durationChanged(self.durationSlider)
    }

    @IBAction func setHour(_ sender: UIButton) {
        self.durationSlider.value = 60
        durationChanged(self.durationSlider)
    }

    override func viewDidLoad() {
        self.durationSlider.value = 5
        self.durationSlider.minimumValue = 1
        self.durationSlider.maximumValue = 120

        durationChanged(self.durationSlider)
    }
}
