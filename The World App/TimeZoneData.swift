//
//  TimeZoneData.swift
//  The World App
//
//  Created by Kyle Stewart on 11/10/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class TimeZoneData {
   
   // LOAD ALL THE TIMEZONES FROM CORE DATA //
   func loadTimeZones(countrySearchText: String = "", locationSearchText: String = "") -> [String: String] {
      
      var timeZones = [String: String] ()
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TimeZones")
      
      request.returnsObjectsAsFaults = false
      
      if locationSearchText != "" {
         
         request.predicate = NSPredicate(format: "location_name contains[c] %@ AND country_name contains[c] %@", locationSearchText, countrySearchText)
         
      } else if countrySearchText != "" {
         
         request.predicate = NSPredicate(format: "country_name contains[c] %@", countrySearchText)
         
      }
      

      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               guard
                  let countryName = result.value(forKey: "country_name") as? String,
                  let locationName = result.value(forKey: "location_name") as? String
                  
                  else {continue}
               
               timeZones[locationName] = countryName
               
            }
            
            
         }
         
         
      } catch {
         
         print("Couldn't get Data")
         
      }
      
      return timeZones
      
   }
   
   /*
   func sectionExists(countryName: String, sectionsArray: [TimeZoneSection]) -> Bool {
      
      var exists = false
      
      for countryTest in sectionsArray {
         
         if countryTest.heading == countryName {
            
            exists = true
            
         }
         
      }
      
      return exists
      
   }
   
   func getLocationArray(countryName: String, sectionsArray: [TimeZoneSection]) -> [String] {
      
      var tempArray = [String] ()
      
      for countryTest in sectionsArray {
         
         if countryTest.heading == countryName {
            
            tempArray = countryTest.items
            
         }
         
      }
      
      return tempArray
      
   }*/
   
}
