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
   func loadTimeZones(countrySearchText: String = "", locationSearchText: String = "") -> [String: GmtOffsetInfo] {
      
      var timeZones = [String: GmtOffsetInfo] ()
      
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
                  let locationName = result.value(forKey: "location_name") as? String,
                  let zoneName = result.value(forKey: "zone_name") as? String,
                  let gmtOffset = result.value(forKey: "gmt_offset") as? Int

               else {continue}
               
               var temp = GmtOffsetInfo(countryCode: nil, countryName: countryName, gmtOffset: gmtOffset, zoneName: zoneName, timestamp: nil, updated: true)
                  
               timeZones[locationName] = temp
               
            }
            
            
         }
         
         
      } catch {
         
         print("Couldn't get Data")
         
      }
      
      return timeZones
      
   }
   
   // LOAD ALL THE TIMEZONES FROM CORE DATA //
   func loadActiveTimeZones() -> [String: GmtOffsetInfo] {
      
      var timeZones = [String: GmtOffsetInfo] ()
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TimeZones")
      
      request.returnsObjectsAsFaults = false
      
      request.predicate = NSPredicate(format: "active == %@", true as CVarArg)
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               guard
                  let countryName = result.value(forKey: "country_name") as? String,
                  let locationName = result.value(forKey: "location_name") as? String,
                  let countryCode = result.value(forKey: "country_code") as? String,
                  let gmtOffset = result.value(forKey: "gmt_offset") as? Int,
                  let zoneName = result.value(forKey: "zone_name") as? String
                  
                  else {continue}
               
               let temp = GmtOffsetInfo(countryCode: countryCode, countryName: countryName, gmtOffset: gmtOffset, zoneName: zoneName, timestamp: nil, updated: true)
               
               timeZones[locationName] = temp
               
            }
            
            
         }
         
         
      } catch {
         
         print("Couldn't get Data")
         
      }
      
      return timeZones
      
   }

   
   /***************************************************************/
   // updateCoreData(), updates the gmtOffset in core data.
   // This is only called if it is different
   /***************************************************************/
   func updateCoreData(zoneToChange: String, newGmtOffset: Any) {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TimeZones")
      
      request.predicate = NSPredicate(format: "zone_name = %@", zoneToChange)
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               
               result.setValue(newGmtOffset, forKey: "gmt_offset")
               
               do {
                  
                  try context.save()
                  print("Time Zone Data Updated")
                  
               } catch {
                  
                  print("Update gmtoffset save failed")
                  
               }
               
            }
            
         }
         
      } catch {
         
         print("Error updating gmtOffset")
         
      }
      
   }
   
   /***************************************************************/
   // saveToCoreData(), to be run after getting JSON file with
   // all of the time zones
   /***************************************************************/
   func saveToCoreData(tempTimeZones: [String: GmtOffsetInfo]) -> Bool {
      
      var isSuccess = false
      
      var numberOfTimeZones = 0
      
      for (locationName, info) in tempTimeZones {
         
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let context = appDelegate.persistentContainer.viewContext
         let data = NSEntityDescription.insertNewObject(forEntityName: "TimeZones", into: context)
         
         data.setValue(info.countryCode, forKey: "country_code")
         data.setValue(info.countryName, forKey: "country_name")
         data.setValue(info.zoneName, forKey: "zone_name")
         data.setValue(info.gmtOffset, forKey: "gmt_offset")
         data.setValue(info.timestamp, forKey: "timestamp")
         data.setValue(locationName, forKey: "location_name")
         data.setValue(false, forKey: "active")
         
         do {
            
            try context.save()
            isSuccess = true
            numberOfTimeZones += 1
            
         } catch {
            
            print("There was an error " + locationName)
            
         }
      }
      
      print("\(numberOfTimeZones) Time Zones Saved")
      
      return isSuccess
      
   }

   /***************************************************************/
   // setActiveFalse(), if clock is removed from table then set
   // active to false in core data
   /***************************************************************/
   func setActiveFalse(zoneName: String) {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TimeZones")
      
      request.returnsObjectsAsFaults = false
      request.predicate = NSPredicate(format: "location_name = %@", zoneName)
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               
               result.setValue(false, forKey: "active")
               
               do {
                  
                  try context.save()
                  
               } catch {
                  
                  print("Change failed")
                  
               }
               
            }
            
         } else {
            
            print("No Results")
            
         }
         
      } catch {
         
         print("Couldn't get Data")
         
      }
      
   }
   
   // SAVE ACTIVE VAR TO TRUE IN CORE DATA //
   func setActiveTrue(locationName: String) {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TimeZones")
      
      request.returnsObjectsAsFaults = false
      request.predicate = NSPredicate(format: "location_name = %@", locationName)
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               
               result.setValue(true, forKey: "active")
               print(locationName + " set to active")
               
               do {
                  
                  try context.save()
                  
                  print("Saved")
                  
                  //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadClocksTable"), object: nil)
                  
               } catch {
                  
                  print("There was an error saving")
                  
               }
               
            }
            
         }
         
      } catch {
         
         print("No Results")
         
      }
      
   }
   
}
