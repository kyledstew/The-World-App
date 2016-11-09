//
//  LanguageSection.swift
//  The World App
//
//  Created by Kyle Stewart on 11/8/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class LanguageSection {

   var heading: String
   var items: [String: Int]
   
   init(title: String, objects: [String: Int]) {
      
      heading = title
      items = objects
      
   }

}
