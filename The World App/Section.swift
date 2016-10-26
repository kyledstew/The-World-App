//
//  Section.swift
//  The World App
//
//  Created by Kyle Stewart on 10/20/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

struct Section {
   
   var heading: String
   var items: [String: CurrencyInfo]
   
   init(title: String, objects: [String: CurrencyInfo]) {
      heading = title
      items = objects
      
   }
   
}

struct CurrencyInfo {
   
   var currency: String
   var timestamp: Int
   
   init(curr: String, time: Int = 0) {
      
      currency = curr
      timestamp = time
      
   }
   
}
