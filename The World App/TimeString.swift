//
//  TimeString.swift
//  The World App
//
//  Created by Kyle Stewart on 11/7/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class TimeString {

   // GET TIME INFO //
   func getTimeString(gmtOffset: Int = 1) -> (dateString: String, timeString: String, updatedTime: String, hour: Int, minute: Int, second: Int) {
      
      let date = NSDate()
      let dateFormatter = DateFormatter()
      if gmtOffset != 1 {
         dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: gmtOffset) as TimeZone!
      }
      dateFormatter.timeStyle = .short
      dateFormatter.locale = NSLocale(localeIdentifier: "en-US") as Locale!
      dateFormatter.dateStyle = DateFormatter.Style.medium
      
      let dateTimeString = dateFormatter.string(from: date as Date)
      let hour = dateFormatter.calendar.component(.hour, from: date as Date)
      let minute = dateFormatter.calendar.component(.minute, from: date as Date)
      let second = dateFormatter.calendar.component(.second, from: date as Date)
      
      var dateString = ""
      var timeString = ""
      var updatedTime = ""
      
      let temp: NSString? = dateTimeString as NSString?
      if let stringArray = temp?.components(separatedBy: ", ") {
         
         dateString = stringArray[0] + ", " + stringArray[1]
         timeString = stringArray.last!
         updatedTime = stringArray[0] + ", " + stringArray.last!
         
      }
      

      
      return (dateString, timeString, updatedTime, hour, minute, second)
      
   }

}
