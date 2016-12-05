//
//  GmtOffset.swift
//  The World App
//
//  Created by Kyle Stewart on 11/25/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class GmtOffset {

   /***************************************************************/
   // checkGmtOffset(), checks the current timeZones to make sure the
   // gmtOffset hasn't changed
   /***************************************************************/
   func checkGmtOffset(locationName: String, gmtOffset: Int, zoneName: String, completionHandler: @escaping (_ noChange: Bool, _ success: Bool) -> Void) {
      
      var noChange = true
      var isSuccess = false
      
      let url = URL(string: "https://api.timezonedb.com/v2/get-time-zone?key=" + APIKeys().getClockAPIKey() + "&format=json&by=zone&zone=" + zoneName + "&fields=gmtOffset")
      
      print(url!)
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            print(error)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  if let currentGmtOffset = jsonResult["gmtOffset"] as? Int {
                     
                     isSuccess = true
                     
                     if currentGmtOffset != gmtOffset { // if the currentGmtOffset is different,
                        noChange = false
                        
                        TimeZoneData().updateCoreData(zoneToChange: zoneName, newGmtOffset: currentGmtOffset) // update it
                        print("gmtOffset different")
                        
                     } else {
                        
                        print("gmtOffset same " + locationName)
                        
                     }
                     
                  }
                  
                  DispatchQueue.main.sync(execute: {
                     
                     completionHandler(noChange, isSuccess)
                     
                  })
                  
               } catch {
                  
                  print("error processing data " + locationName)
                  completionHandler(noChange, isSuccess)
                  
               }
               
            }
         }
         
      }
      task.resume()
      
   }


}
