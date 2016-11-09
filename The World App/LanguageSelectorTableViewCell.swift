//
//  LanguageSelectorTableViewCell.swift
//  The World App
//
//  Created by Kyle Stewart on 11/8/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class LanguageSelectorTableViewCell: UITableViewCell {

   @IBOutlet var languageLabel: UILabel!
   @IBOutlet var checkMark: UIImageView!
   
   override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
