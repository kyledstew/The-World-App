//
//  WeatherDataApi.swift
//  The World App
//
//  Created by Kyle Stewart on 11/30/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class WeatherDataApi {
   
   // Get Data for the location entered
   func getWeatherData(location: String, refreshDataRequest: Bool = false, completeHandler:@escaping (_ success: Bool, _ errorType: String, _ message: String) -> Void) {
      
      var success = false
      var errorType = "generic"
      var message = "An unknown error occurred. Please try again."
      
      let encodedURL = location.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)
      
      let urlString = "http://api.openweathermap.org/data/2.5/weather?q=" + encodedURL! +  "&appid=" + APIKeys().getWeatherAPIKey() + "&units=metric"
      
      let url = URL(string: urlString)
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            errorType = "connection_error"
            message = "Unable to download current weather data. Please make sure The World App has access to cellular data"
            
            print(error!)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  if (jsonResult["message"] as? String) != nil {
                     
                     message = "No location found for " + location
                     
                  } else {
                     
                     if let locationName = jsonResult["name"] as? String {
                        
                        if !self.dataExists(locationName: locationName) || refreshDataRequest {
                           
                           if locationName == location.capitalized ||
                              locationName + " " == location.capitalized
                              
                           { // Sometimes the result is different then what we searched. Make sure it's the same!
                              
                              var currentWeather = ""
                              var icon = ""
                              
                              let weatherDescriptionArray = jsonResult["weather"] as! [[String: AnyObject]]
                              
                              for wda in weatherDescriptionArray {
                                 
                                 currentWeather = wda["description"] as! String
                                 icon = wda["icon"] as! String
                                 
                              }
                              
                              if let mainArray = jsonResult["main"] {
                                 
                                 let currentTemp = mainArray["temp"]! as! Double
                                 let dt = jsonResult["dt"] as! Int
                                 if let sysArray = jsonResult["sys"] {
                                    let sunrise = sysArray["sunrise"] as! Int
                                    let sunset = sysArray["sunset"] as! Int
                                    
                                    let temp = WeatherInfo(currentTemp: currentTemp, currentWeather: currentWeather, sunrise: sunrise, sunset: sunset, dt: dt, icon: icon)
                                       
                                       if WeatherData().saveToCoreData(location: locationName, info: temp) {
                                          
                                          success = true
                                          errorType = ""
                                          message = ""
                                          
                                       } else { // Error when saving
                                          
                                          message = "An error occurred when saving Data. Please try again."
                                          
                                       }
                                    
                                 }
                              }
                           } else { // result didn't match search
                           
                              message = "No location found for " + location
                              
                           }
                           
                        } else {    // DATA ALREADY EXISTS
                           
                           message = locationName + " already exists"
                           
                        }
                        
                     }
                     
                  }
                  
               } catch {
                  
                  print("Error processing failed")
                  
                  
               }
               
            }
            
         }
         
         DispatchQueue.main.sync(execute: {
            
            completeHandler(success, errorType, message)
            
         })
         
      }
      
      task.resume()
      
   }
   
   func dataExists(locationName: String ) -> Bool {
      
      var exists = false
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
      
      request.predicate = NSPredicate(format: "location_name = %@", locationName)
      
      request.returnsObjectsAsFaults = false
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               
               if result.value(forKey: "location_name") != nil
               {
                  
                  exists = true
                  
               }
               
            }
            
         } else {
            
            print("No Results")
            
         }
         
      } catch {
         
         print("Couldn't get Data")
         
      }
      
      return exists
      
   }
   
   
   // REFRESH WEATHER DATA //
   func refreshData(completeHandler: @escaping (_ success: Bool, _ errorType: String, _ message: String) -> Void) {
      
      var success = false
      var errorType = "generic"
      var message = "An unknown error occurred. Please try again."
      
      let weather = WeatherData().loadWeather()
      
      if weather.count > 0 {
         
         for locationName in weather.keys {
            
            getWeatherData(location: locationName, refreshDataRequest: true, completeHandler: { (success_get, errorType_get, message_get) in
               if success_get {
                  
                  success = true
                  errorType = ""
                  message = ""
                  
               } else {
                  
                  errorType = errorType_get
                  message = message_get
                  
               }
               
               completeHandler(success, errorType, message)
               
            })
            
         }
         
      }
      
      
      
   }
   
}
