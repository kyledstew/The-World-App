//
//  CurrencySelectorTableViewCell.swift
//  The World App
//
//  Created by Kyle Stewart on 10/19/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class CurrencySelectorTableViewCell: UITableViewCell {

   @IBOutlet var checkMark: UIImageView!
   @IBOutlet var currencyAbr: UILabel!
   @IBOutlet var currencyLongName: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
