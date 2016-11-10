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
   struct weatherInfo {
      
      var currentTemp: Double?
      var currentWeather: String?
      var icon: String?
   }
   var locationWeatherInfo = [String: weatherInfo] ()
   
   // UI ITEMS //
   @IBOutlet var selectedUnit: UISegmentedControl!
   @IBOutlet var table: UITableView!
   @IBOutlet var dataUpdatedNotice: UILabel!
   @IBOutlet var loader: UIActivityIndicatorView!
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
      
      let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(WeatherViewController.refreshData))
      swipeDown.direction = UISwipeGestureRecognizerDirection.down
      self.view.addGestureRecognizer(swipeDown)
      
      NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.loadData),name:NSNotification.Name(rawValue: "reloadWeatherTable"), object: nil)
      
      NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.loadData),name:NSNotification.Name(rawValue: "AddWeatherLocationPopupClosed"), object: nil)
      
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   // VIEW DID APPEAR //
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(true)
      
      loadData()
      
      if locationWeatherInfo.count == 0 {
         
         loader.stopAnimating()
         
      } else {
         
         addLocationPrompt.isHidden = true
         
      }
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
      
      return locationWeatherInfo.count
      
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      var tempArray = Array(locationWeatherInfo.keys).sorted()
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as! WeatherTableViewCell// prototype
      
      cell.locationNameLabel.text = tempArray[indexPath.row]
      
      var currentTemp = locationWeatherInfo[tempArray[indexPath.row]]?.currentTemp
      
      if !metric {
         
         currentTemp = (currentTemp! * (9/5)) + 32
         
      }
      
      cell.currentTempLabel.text = String(Int(currentTemp!)) + "˚"
      
      cell.currentWeatherDescription.text = locationWeatherInfo[tempArray[indexPath.row]]?.currentWeather?.capitalized
      
      
      return cell // return cell
      
   }
   
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == UITableViewCellEditingStyle.delete {
         
         let locationName = Array(locationWeatherInfo.keys).sorted()[indexPath.row]
         
         deleteData(locationName: locationName)
         locationWeatherInfo[locationName] = nil
         
         table.reloadData()
         
         if locationWeatherInfo.count == 0 {
            
            addLocationPrompt.isHidden = false
            dataUpdatedNotice.isHidden = true
            
         }
         
      }
      
   }
   
   // LOAD DATA FROM CORE DATA //
   func loadData(){
      
      BlurVisualEffectViewController().disableBlur(temp: self)
      loader.startAnimating()
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
      
      request.returnsObjectsAsFaults = false
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            addLocationPrompt.isHidden = true
            
            for result in results as! [NSManagedObject] {
               
               if let locationName = result.value(forKey: "location_name") {
                  
                  if let currTemp = result.value(forKey: "current_temp") as? Double {
                     
                     if let currWeather = result.value(forKey: "weather_description") as? String{
                        
                        if let icon = result.value(forKey: "icon") as? String {
                           
                           let temp = weatherInfo(currentTemp: currTemp, currentWeather: currWeather, icon: icon)
                           
                           locationWeatherInfo[locationName as! String] = temp
                           
                        }
                     }
                     
                  }
                  
               }
               
            }
            
            table.reloadData()
            
            loader.stopAnimating()
            
            if locationWeatherInfo.count > 0 {
               dataUpdatedNotice.isHidden = false
               
               self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(WeatherViewController.fadeOutAlert), userInfo: nil, repeats: true)
            }
            
         } else {
            
            print("No Results")
            
         }
         
      } catch {
         
         print("Couldn't get Data")
         
      }
      
      
   }
   
   // DELETE DATA FOR THE LOCATION SELECTED //
   func deleteData(locationName: String) {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
      
      request.predicate = NSPredicate(format: "location_name = %@", locationName)
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               
               context.delete(result)
               
               do {
                  
                  try context.save()
                  
               } catch {
                  
                  print("delete failed")
                  
               }
               
            }
            
         } else {
            
            print("No Results")
            
         }
         
      } catch {
         
         print("Couldn't get Data")
         
      }
      
   }
   
   // REFRESH WEATHER DATA //
   func refreshData() {
      
      print("TEST")
      
      if locationWeatherInfo.count > 0 {
         
         loader.startAnimating()
         
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let context = appDelegate.persistentContainer.viewContext
         let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
         
         request.returnsObjectsAsFaults = false
         
         do {
            
            let results = try context.fetch(request)
            
            if results.count > 0 {
               
               for result in results as! [NSManagedObject] {
                  
                  if let locationName = result.value(forKey: "location_name") {
                     
                     getAPIData(locationName: locationName as! String)
                     
                  }
                  
               }
               allDataRefreshed = true
               
            } else {
               
               print("No Results")
               
            }
            
         } catch {
            
            print("Couldn't get Data")
            
         }
      }
      table.reloadData()
      
   }
   
   // GET WEATHER FOR THE LOCATIONS //
   func getAPIData(locationName: String) {
      
      let encodedURL = locationName.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)
      
      let urlString = "http://api.openweathermap.org/data/2.5/weather?q=" + encodedURL! +  "&appid=" + APIKeys().getWeatherAPIKey() + "&units=metric"
      
      let url = URL(string: urlString)
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            print(error)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  if let locationNameNew = jsonResult["name"] as? String {
                     
                     if let lon = jsonResult["coord"]?["lon"] as? Double {
                        
                        if let lat = jsonResult["coord"]?["lat"] as? Double {
                           
                           var weatherDescription = ""
                           var icon = ""
                           
                           let weatherDescriptionArray = jsonResult["weather"] as! [[String: AnyObject]]
                           
                           print(weatherDescriptionArray)
                           
                           for wda in weatherDescriptionArray {
                              
                              weatherDescription = wda["description"] as! String
                              icon = wda["icon"] as! String
                              
                           }
                           
                           if let mainArray = jsonResult["main"] {
                              
                              let currentTemp = mainArray["temp"]!
                              
                              let humidity = mainArray["humidity"]!
                              
                              let tempMin = mainArray["temp_min"]!
                              
                              let tempMax = mainArray["temp_max"]
                              
                              let appDelegate = UIApplication.shared.delegate as! AppDelegate
                              let context = appDelegate.persistentContainer.viewContext
                              let weatherInfo = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
                              
                              weatherInfo.predicate = NSPredicate(format: "location_name = %@", locationName)
                              
                              do {
                                 
                                 let results = try context.fetch(weatherInfo)
                                 
                                 if results.count > 0 {
                                    
                                    for result in results as! [NSManagedObject] {
                                       
                                       result.setValue(locationNameNew, forKey: "location_name")
                                       result.setValue(lat, forKey: "lat")
                                       result.setValue(lon, forKey: "lon")
                                       result.setValue(weatherDescription, forKey: "weather_description")
                                       result.setValue(icon, forKey: "icon")
                                       result.setValue(currentTemp!, forKey: "current_temp")
                                       result.setValue(humidity!, forKey: "humidity")
                                       result.setValue(tempMin!, forKey: "temp_min")
                                       result.setValue(tempMax!, forKey: "temp_max")
                                       
                                       
                                       do {
                                          
                                          try context.save()
                                          
                                       } catch {
                                          
                                          print("Unable to update weather")
                                          
                                       }
                                       
                                       DispatchQueue.main.sync(execute: {
                                          
                                          self.loadData()
                                          
                                          
                                       })
                                    }
                                 }
                                 
                              }
                           }
                        }
                     }
                  }
                  
               } catch {
                  print("Error processing failed")
               }
               
            }
            
         }
         
      }
      
      task.resume()
      
   }
   
   // FADE OUT THE UPDATE NOTICE //
   func fadeOutAlert() {
      
      dataUpdatedNotice.isHidden = true
      timer.invalidate()
   }
   
}



