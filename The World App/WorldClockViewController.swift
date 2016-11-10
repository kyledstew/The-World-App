//
//  WorldClockViewController.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 9/16/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class WorldClockViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
   // VARIABLES //
   private var timer = Timer()
   var timeZones = [String: GmtOffset] ()  // Key is the location_name, and gmt_offset is the value
   var currentMinute: Int?
   var firstTime = true
   var firstTimeLoadComplete = false
   struct GmtOffset {
      
      var countryCode: String?
      var countryName: String?
      var gmtOffset: Int?
      var zoneName: String?
      var timestamp: Int?
      var updated = false
      
   }
   
   // UI ITEMS //
   @IBOutlet var table: UITableView!
   @IBOutlet var loader: UIActivityIndicatorView!
   @IBOutlet var addClockPrompt: UILabel!
   @IBOutlet var addLocationButton: UIBarButtonItem!
   
   // VIEW DID LOAD //
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // If first time loading app, we need to pull all the data.
      if let temp = UserDefaults.standard.object(forKey: "firstTimeLoadingTimeZones") as? Bool {
         
         firstTime = temp
         
      }
      
      if firstTime {
         
         getTimeZoneInfo()
         
      } else {
         
         loadTimeZones()
         addLocationButton.isEnabled = true
         
      }
      
      // Update the time every second
      timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(WorldClockViewController.updateTime), userInfo: nil, repeats: true)
      
      NotificationCenter.default.addObserver(self, selector: #selector(WorldClockViewController.loadTimeZones),name:NSNotification.Name(rawValue: "AddTimeZonePopupClosed"), object: nil)
      
   }
   
   // VIEWDIDAPPEAR //
   override func viewDidAppear(_ animated: Bool) {

      if !firstTime {
         
         loadTimeZones()
         
         if timeZones.count == 0 {
            
            loader.stopAnimating()
            
         } else {
            
            addClockPrompt.isHidden = true
            
         }
         
      }
      
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
      if segue.identifier == "toTimeZoneSelector" {
         
         BlurVisualEffectViewController().enableBlur(temp: self)
         
      }
      
   }
   
   /***************************************************************/
   // loadTimeZones(), pulls all timeZones that have a active of true set
   // then checks to see if gmtOffset has changed (daylight savings)
   /***************************************************************/
   func loadTimeZones() {
      
      BlurVisualEffectViewController().disableBlur(temp: self)
      loader.startAnimating()
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TimeZones")
      
      request.returnsObjectsAsFaults = false
      request.predicate = NSPredicate(format: "active == true")
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            addClockPrompt.isHidden = true
            
            for result in results as! [NSManagedObject] {
               
               if let locationName = result.value(forKey: "location_name") as? String {
                  
                  if let gmtOffset = result.value(forKey: "gmt_offset") as? Int {
                     
                     if let zoneName = result.value(forKey: "zone_name") as? String {
                        
                        if zoneName == "Pacific/Pago_Pago" {
                           
                           print(zoneName + " \(gmtOffset)")
                           
                        }
                        
                        if timeZones[locationName] == nil { // If nil, it's new
                           
                           let temp = GmtOffset(countryCode: nil, countryName: nil, gmtOffset: gmtOffset, zoneName: zoneName, timestamp: nil, updated: true)
                           
                           self.timeZones[locationName] = temp
                           checkGmtOffset(locationName: locationName, gmtOffset: gmtOffset, zoneName: zoneName)
                           
                        }
                        
                        loader.stopAnimating()
                        table.reloadData()
                        
                     }
                     
                  }
                  
               }
               
            }
            
         } else {
            
            loader.stopAnimating()
            print("No variables set to active")
            
         }
         
      } catch {
         
         print("No Data")
         
      }
      
   }
   
   /***************************************************************/
   // checkGmtOffset(), checks the current timeZones to make sure the
   // gmtOffset hasn't changed
   /***************************************************************/
   func checkGmtOffset(locationName: String, gmtOffset: Int, zoneName: String) {
      
      let url = URL(string: "https://api.timezonedb.com/v2/get-time-zone?key=" + APIKeys().getClockAPIKey() + "&format=json&by=zone&zone=" + zoneName)
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            print(error)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  if let currentGmtOffset = jsonResult["gmtOffset"] as? Int {
                     
                     print("Current \(currentGmtOffset)")
                     
                     let temp = GmtOffset(countryCode: nil, countryName: nil, gmtOffset: gmtOffset, zoneName: zoneName, timestamp: nil, updated: true)
                     self.timeZones[locationName] = temp
                     self.table.reloadData()
                     self.loader.stopAnimating()
                     
                     if currentGmtOffset != gmtOffset { // if the currentGmtOffset is different,
                        
                        self.updateCoreData(zoneToChange: zoneName, newGmtOffset: currentGmtOffset) // update it
                        print("gmtOffset different")
                        
                     } else {
                        
                        print("gmtOffset same")
                        
                        
                     }
                     
                     
                     
                  }
                  
                  DispatchQueue.main.sync(execute: {
                     
                     
                  })
                  
                  
                  
               } catch {
                  
                  print("error processing data")
                  
               }
               
            }
         }
         
      }
      task.resume()
      
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
   
   /***************************************************************/
   // getTimeZoneInfo(), only called first time the app is loaded.
   // it gets all of the timezones support by the api
   /***************************************************************/
   func getTimeZoneInfo() {
      
      let url = URL(string: "https://api.timezonedb.com/v2/list-time-zone?key=" + APIKeys().getClockAPIKey() + "&format=json")
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            print(error)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  var tempTimeZones = [String: GmtOffset] ()
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  if let timeZonesArray = jsonResult["zones"] as? [[String: AnyObject]] {
                     
                     for timeZones in timeZonesArray {
                        
                        if let countryCode = timeZones["countryCode"] as? String {
                           
                           if let countryName = timeZones["countryName"] as? String {
                              
                              if let zoneName = timeZones["zoneName"] as? String {
                                 
                                 if let gmtOffset = timeZones["gmtOffset"] as? Int {
                                    
                                    if let timestamp = timeZones["timestamp"] as? Int {
                                       
                                       if zoneName == "Pacific/Pago_Pago" {
                                          
                                          print(zoneName + " \(gmtOffset)")
                                          
                                       }
                                       
                                       let temp = GmtOffset(countryCode: countryCode, countryName: countryName, gmtOffset: gmtOffset, zoneName: zoneName, timestamp: timestamp, updated: true)
                                       tempTimeZones[self.getLocationName(zoneName: zoneName)] = temp
                                       
                                    }
                                    
                                 }
                                 
                              }
                              
                           }
                           
                        }
                        
                     }
                     
                     DispatchQueue.main.sync(execute: {
                        
                        if self.saveToCoreData(tempTimeZones: tempTimeZones) {
                           self.firstTime = false
                           UserDefaults.standard.set(self.firstTime, forKey: "firstTimeLoadingTimeZones")
                        }
                        
                     })
                     
                  }
                  
               } catch {
                  
                  print("error processing data")
                  self.getTimeZoneInfo()
                  
               }
               
            }
         }
         
      }
      task.resume()
      
   }
   
   /***************************************************************/
   // saveToCoreData(), to be run after getting JSON file with
   // all of the time zones
   /***************************************************************/
   func saveToCoreData(tempTimeZones: [String: GmtOffset]) -> Bool {
      
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
         
         if info.zoneName == "Pacific/Pago_Pago" {
            
            print(info.zoneName! + " \(info.gmtOffset)")
            
         }
         
         do {
            
            try context.save()
            isSuccess = true
            numberOfTimeZones += 1
            
         } catch {
            
            print("There was an error " + locationName)
            
         }
      }
      
      print("\(numberOfTimeZones) Time Zones Saved")
      
      self.loadTimeZones()
      self.addLocationButton.isEnabled = true
      
      return isSuccess
      
   }
   
   /***************** Functions to check whether time has changed ****************/
   func updateTime() {
      
      if dateChange() {
         
         table.reloadData()
         
      }
      
   }
   
   func dateChange() -> Bool {
      
      var change = false
      
      if timeZones.count != 0 {
         
         if currentMinute == TimeString().getTimeString().minute {
            
            change = false
            
         } else {
            
            change = true
            
         }
      } else {
         
         change = false
         
      }
      
      return change
      
   }
   /******************************************************************************/
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
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
   
   /***************************************************************/
   // deleteAllData(), deletes all the data in a specific entity
   // used for testing purposes
   /***************************************************************/
   func deleteAllData(entity: String)
   {
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let managedContext = appDelegate.persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
      fetchRequest.returnsObjectsAsFaults = false
      
      var i = 1
      
      do
      {
         let results = try managedContext.fetch(fetchRequest)
         if results.count > 0 {
            for managedObject in results
            {
               let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
               managedContext.delete(managedObjectData)
               print("Deleted \(i)")
               i += 1
            }
         }
         
         do {
            try managedContext.save()
            
            print("SAVED")
         } catch {
            
            
         }
      } catch let error as NSError {
         print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
      }
   }
   

   
   /************************* TABLE FUNCTIONS *********************************/
   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      return timeZones.count
      
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      let timeZonesArray = Array(timeZones.keys).sorted()
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "ClockTableViewCell", for: indexPath) as! ClockTableViewCell
      
      cell.locationNameLabel.text = timeZonesArray[indexPath.row]
      cell.timeLabel.text = String(TimeString().getTimeString(gmtOffset: (timeZones[timeZonesArray[indexPath.row]]?.gmtOffset!)!).timeString)
      cell.dateLabel.text = String(TimeString().getTimeString(gmtOffset: (timeZones[timeZonesArray[indexPath.row]]?.gmtOffset!)!).dateString)
      
      
      currentMinute = TimeString().getTimeString(gmtOffset: (timeZones[timeZonesArray[indexPath.row]]?.gmtOffset!)!).minute
      
      return cell
      
   }
   
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == UITableViewCellEditingStyle.delete {
         
         let zoneName = Array(timeZones.keys).sorted()[indexPath.row]
         
         setActiveFalse(zoneName: zoneName)
         timeZones[zoneName] = nil
         
         table.reloadData()
         
         if timeZones.count == 0 {
            
            addClockPrompt.isHidden = false
            
         }
         
      }
      
   }
   
   /*******************************************************************************/
   
   
}


