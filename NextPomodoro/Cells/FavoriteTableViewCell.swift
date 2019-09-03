//
//  FavoriteTableViewCell.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/03.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit
import SDWebImage

class FavoriteTableViewCell: UITableViewCell, ReusableCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!

    var favorite: Favorite! {
        didSet {
            titleLabel.text = favorite.title
            categoryLabel.text  = favorite.category
            durationLabel.text = ApplicationSettings.shortTime(favorite!.duration)!
            countLabel.text = "\(favorite.count)"

            if let icon = favorite.icon {
                iconImage.sd_setImage(with: URL(string: icon), placeholderImage: nil, options: SDWebImageOptions.scaleDownLargeImages, completed: nil)
            }
        }
    }
}
