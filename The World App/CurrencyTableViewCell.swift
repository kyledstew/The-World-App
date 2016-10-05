//
//  CurrencyTableViewCell.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 9/28/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

   @IBOutlet var sourceCurrencyAmountLabel: UILabel!
   @IBOutlet var sourceCurrencyLabel: UILabel!
   @IBOutlet var targetCurrencyAmountLabel: UILabel!
   @IBOutlet var targetCurrencyLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
