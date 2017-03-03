//
//  CurrencyInfo.swift
//  The World App
//
//  Created by Kyle Stewart on 11/9/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

struct CurrencyInfo {
   
   var currency: String
   var timestamp: Int
   
   init(curr: String, time: Int = 0) {
      
      currency = curr
      timestamp = time
      
   }
   
}
