//
//  ClockTableViewCell.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 9/27/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class ClockTableViewCell: UITableViewCell {

   @IBOutlet var locationNameLabel: UILabel!
   @IBOutlet var timeLabel: UILabel!
   @IBOutlet var dateLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
