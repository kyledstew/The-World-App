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
   var timeZones = [String: GmtOffsetInfo] ()  // Key is the location_name
   var currentMinute: Int?
   
   // UI ITEMS //
   @IBOutlet var table: UITableView!
   @IBOutlet var loader: UIActivityIndicatorView!
   @IBOutlet var addClockPrompt: UILabel!
   @IBOutlet var addLocationButton: UIBarButtonItem!
   
   // VIEW DID LOAD //
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // If first time loading app, we need to pull all the data.
      if (UserDefaults.standard.object(forKey: "firstTimeLoadingTimeZones") as? Bool) == nil {
         
         loader.startAnimating()
         
         FirstTime().getTimeZoneInfo(completionHandler: {( success, errorType, message ) -> Void in
            
            if success {
               
               self.addLocationButton.isEnabled = true
               self.loader.stopAnimating()
               
            } else {
               
               self.loader.stopAnimating()
               AlertsViewController().errorMessage(currentViewController: self, errorType: errorType, message: message)
               
            }
            
         })
         
      } else {
         
         reloadActiveTimeZones()
         
         checkGmtOffset()

         addLocationButton.isEnabled = true
         
      }
      
      // Update the time every second
      timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(WorldClockViewController.updateTime), userInfo: nil, repeats: true)
      
      NotificationCenter.default.addObserver(self, selector: #selector(reloadActiveTimeZones), name: NSNotification.Name(rawValue: "AddTimeZonePopupClosed"), object: nil)
      

      
   }
   
   func checkGmtOffset(i: Int = 0) {
      
      var tempArray = Array(timeZones.keys).sorted()
      
      if i < tempArray.count && tempArray.count != 0 {
      
         print("Check " + tempArray[i])
               
            GmtOffset().checkGmtOffset(locationName: tempArray[i], gmtOffset: (timeZones[tempArray[i]]?.gmtOffset!)!, zoneName: (timeZones[tempArray[i]]?.zoneName!)!, completionHandler: { (noChange, isSuccess) in
                  
                  if isSuccess {
                  
                     if !noChange {
                     
                        self.timeZones = TimeZoneData().loadActiveTimeZones()
                     
                     }
                  
                     self.checkGmtOffset(i: i+1)
                     
                  } else {
                     
                     print("Try again")
                     
                     self.checkGmtOffset(i: i)
                     
                  }
                  
               })
   
         self.reloadActiveTimeZones()
      }
   
   }
   

   func reloadActiveTimeZones() {
      
      BlurVisualEffectViewController().disableBlur(temp: self)
      
      timeZones = TimeZoneData().loadActiveTimeZones()
      
      table.reloadData()
      
   }
   
   // VIEWDIDAPPEAR //
   override func viewDidAppear(_ animated: Bool) {
      
      reloadActiveTimeZones()
      
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
      if segue.identifier == "toTimeZoneSelector" {
         
         BlurVisualEffectViewController().enableBlur(temp: self)
         
      }
      
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
   
   /************************* TABLE FUNCTIONS *********************************/
   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      if timeZones.count > 0 {
         
         addClockPrompt.isHidden = true
         
      }
      
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
         
         TimeZoneData().setActiveFalse(zoneName: zoneName)
         timeZones[zoneName] = nil
         
         table.reloadData()
         
         if timeZones.count == 0 {
            
            addClockPrompt.isHidden = false
            
         }
         
      }
      
   }
   
   /*******************************************************************************/
   
   
}


