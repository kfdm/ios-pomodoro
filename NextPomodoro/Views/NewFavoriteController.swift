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

    @IBAction func submitNewFavorite(_ sender: UIButton) {
        guard let title = titleText.text else { return }
        guard let category = categoryText.text else { return }

        let favorite = Favorite.init(id: 0, title: title, duration: 5, category: category, owner: "", icon: nil, count: 0)
        favorite.submit(completionHandler: {favorite in
            print(favorite)
           self.navigationController?.popToRootViewController(animated: true)
        })
    }
}
