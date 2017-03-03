//
//  FirstTime.swift
//  The World App
//
//  Created by Kyle Stewart on 11/25/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class FirstTime {
   
   /***************************************************************/
   // getTimeZoneInfo(), only called first time the app is loaded.
   // it gets all of the timezones support by the api
   /***************************************************************/
   func getTimeZoneInfo(completionHandler: @escaping (_ success: Bool, _ errorType: String, _ message: String) -> Void) {
      
      var success = false
      var errorType = "generic"
      var message = "An unkown error occurred. Please try again."
      
      var tempTimeZones = [String: GmtOffsetInfo] ()
      
      let url = URL(string: "https://api.timezonedb.com/v2/list-time-zone?key=" + APIKeys().getClockAPIKey() + "&format=json&fields=countryCode,countryName,zoneName,gmtOffset,timestamp")
      print(url!)
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            errorType = "connection_error"
            message = "Unable to download world clocks. Please make sure The World App has access to cellular data"
            
            print(error!)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  if let timeZonesArray = jsonResult["zones"] as? [[String: AnyObject]] {
                     
                     for timeZones in timeZonesArray {
                        
                        let countryCode = timeZones["countryCode"] as? String
                        let countryName = timeZones["countryName"] as? String
                        let zoneName = timeZones["zoneName"] as? String
                        let gmtOffset = timeZones["gmtOffset"] as? Int
                        let timestamp = timeZones["timestamp"] as? Int
                        
                        let temp = GmtOffsetInfo(countryCode: countryCode, countryName: countryName, gmtOffset: gmtOffset, zoneName: zoneName, timestamp: timestamp, updated: true)
                        
                        tempTimeZones[self.getLocationName(zoneName: zoneName!)] = temp
                        
                     }
                     
                  }
                  
               } catch {
                  
                  print("error processing data")
                  
               }
               
            }
         }
         
         DispatchQueue.main.sync(execute: {
            
            if TimeZoneData().saveToCoreData(tempTimeZones: tempTimeZones) {
               
               success = true
               errorType = ""
               message = ""
               UserDefaults.standard.set(false, forKey: "firstTimeLoadingTimeZones")
               
            } else {
               
               message = "An error occurred when saving Data. Please try again."
               
            }
      
            completionHandler(success, errorType, message)
            
         })
         
      }
      task.resume()
      
   }
   
   /***************************************************************/
   // getLocationName(), splits the zone name to get the last name
   // E.g., Name1/Name2/Name3, it returns Name3 to be used in picker
   /***************************************************************/
   func getLocationName(zoneName: String) -> String {
      
      var locationName = ""
      
      let temp: NSString? = zoneName as NSString?  // Get the key to split up
      
      if let stringArray = temp?.components(separatedBy: "/") { // split by character /
         
         locationName = stringArray.last! // Get the last element
      }
      
      return locationName.replacingOccurrences(of: "_", with: " ")
      
   }
   
   
}
