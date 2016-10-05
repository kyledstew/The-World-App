//
//  WeatherTableViewCell.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 9/27/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {

   @IBOutlet var locationNameLabel: UILabel!
   //@IBOutlet var loadingIcon: UIActivityIndicatorView!
   //@IBOutlet var weatherIconImage: UIImageView!
   @IBOutlet var currentTempLabel: UILabel!
   @IBOutlet var currentWeatherDescription: UILabel!

   
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
