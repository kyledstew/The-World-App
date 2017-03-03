//
//  TranslationsTableViewCell.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 10/2/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class TranslationsTableViewCell: UITableViewCell {

   @IBOutlet var sourceLanguageLabel: UILabel!
   @IBOutlet var targetLanguageLabel: UILabel!
   @IBOutlet var textToTranslateLabel: UITextView!
   @IBOutlet var translatedTextLabel: UITextView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
