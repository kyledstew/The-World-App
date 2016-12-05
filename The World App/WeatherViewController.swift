//
//  WeatherViewController.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 9/14/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class WeatherViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
   // VARIABLES //
   var timer = Timer()
   var metric = true // 0 is metric, the default
   var allDataRefreshed = false
   var refresher: UIRefreshControl!
   
   var weatherInfo = WeatherData().loadWeather()
   
   // UI ITEMS //
   @IBOutlet var selectedUnit: UISegmentedControl!
   @IBOutlet var table: UITableView!
   @IBOutlet var dataUpdatedNotice: UILabel!
   @IBOutlet var addLocationPrompt: UILabel!
   
   // UI ITEM FUNCS //
   @IBAction func metricChanged(_ sender: AnyObject) {
      
      if selectedUnit.selectedSegmentIndex == 0 {
         
         metric = true
         
      } else {
         
         metric = false
         
      }
      
      table.reloadData()
      
   }
   
   // VIEW DID LOAD //
   override func viewDidLoad() {
      super.viewDidLoad()
      
      NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.popupClosed),name:NSNotification.Name(rawValue: "AddWeatherLocationPopupClosed"), object: nil)
      
      weatherInfo = WeatherData().loadWeather()
      
      refresher = UIRefreshControl()
      refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
      refresher.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
      table.addSubview(refresher)
      
   }
   
   func refreshData() {
      
      if weatherInfo.count == 0 {
         
         refresher.endRefreshing()
         
      } else {
         
         WeatherDataApi().refreshData { (success, errorType, message) in
            
            if success {
               
               self.weatherInfo = WeatherData().loadWeather()
               self.dataUpdatedNotice.isHidden = false
               self.table.reloadData()
               self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(WeatherViewController.fadeOutAlert), userInfo: nil, repeats: true)
               
            } else {
               
               AlertsViewController().errorMessage(currentViewController: self, errorType: errorType, message: message)
               
            }
            
            self.refresher.endRefreshing()
            
         }
      }
      
      
   }
   
   func popupClosed() {
      
      BlurVisualEffectViewController().disableBlur(temp: self)
      
      weatherInfo = WeatherData().loadWeather()
      
      self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(WeatherViewController.fadeOutAlert), userInfo: nil, repeats: true)
      
      table.reloadData()
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   // VIEW DID APPEAR //
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(true)
      
      weatherInfo = WeatherData().loadWeather()
      
      table.reloadData()
      
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
      if segue.identifier == "toWeatherAdder" {
         
         BlurVisualEffectViewController().enableBlur(temp: self)
         
      }
      
   }
   
   /***************************************************************/
   //               !!!TABLE FUNCTIONS!!!
   /***************************************************************/
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      if weatherInfo.count > 0 {
         
         addLocationPrompt.isHidden = true
         
         dataUpdatedNotice.isHidden = false
         
         self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(WeatherViewController.fadeOutAlert), userInfo: nil, repeats: true)
         
      } else {
         
         addLocationPrompt.isHidden = false
         
      }
      
      return weatherInfo.count
      
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      var tempArray = Array(weatherInfo.keys).sorted()
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as! WeatherTableViewCell// prototype
      
      cell.locationNameLabel.text = tempArray[indexPath.row]
      
      var currentTemp = weatherInfo[tempArray[indexPath.row]]?.currentTemp
      
      if !metric {
         
         currentTemp = (currentTemp! * (9/5)) + 32
         
      }
      
      cell.currentTempLabel.text = String(Int(currentTemp!)) + "˚"
      
      /*
       if Int(NSDate().timeIntervalSince1970) > (weatherInfo[tempArray[indexPath.row]]?.sunset)! {
       
       cell.currentWeatherDescription.text = weatherInfo[tempArray[indexPath.row]]?.currentWeather?.capitalized
       cell.backgroundColor = UIColor.black.withAlphaComponent(0.6)
       cell.currentTempLabel.textColor = UIColor.white
       cell.currentWeatherDescription.textColor = UIColor.white
       cell.locationNameLabel.textColor = UIColor.white
       }*/
      
      return cell // return cell
      
   }
   
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == UITableViewCellEditingStyle.delete {
         
         let locationName = Array(weatherInfo.keys).sorted()[indexPath.row]
         
         WeatherData().deleteData(locationName: locationName)
         weatherInfo[locationName] = nil
         
         table.reloadData()
         
         if weatherInfo.count == 0 {
            
            addLocationPrompt.isHidden = false
            dataUpdatedNotice.isHidden = true
            
         }
         
      }
      
   }
   
   // FADE OUT THE UPDATE NOTICE //
   func fadeOutAlert() {
      
      dataUpdatedNotice.isHidden = true
      timer.invalidate()
   }
   
}



