//
//  WeatherData.swift
//  The World App
//
//  Created by Kyle Stewart on 11/18/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class WeatherData {

   func loadWeather() -> [String: WeatherInfo] {
      
      var weatherData = [String: WeatherInfo] ()
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
      
      request.returnsObjectsAsFaults = false
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               
               guard
                  let locationName = result.value(forKey: "location_name") as? String,
                  let currTemp = result.value(forKey: "current_temp") as? Double,
                  let currWeather = result.value(forKey: "weather_description") as? String,
                  let sunrise = result.value(forKey: "sunrise") as? Int,
                  let sunset = result.value(forKey: "sunset") as? Int,
                  let icon = result.value(forKey: "icon") as? String,
                  let dt = result.value(forKey: "dt") as? Int
                  
                  else {continue}
               
               let temp = WeatherInfo(currentTemp: currTemp, currentWeather: currWeather, sunrise: sunrise, sunset: sunset, dt: dt, icon: icon)
               
               weatherData[locationName] = temp
               
            }
            
         } else {
            
            print("No Results")
            
         }
         
      } catch {
         
         print("Couldn't get Data")
         
      }
      
      return weatherData
      
   }
   
   func saveToCoreData(location: String, info: WeatherInfo) -> Bool {
      
      var sucess = false
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let weatherInfo = NSEntityDescription.insertNewObject(forEntityName: "Weather", into: context)
      
      weatherInfo.setValue(location, forKey: "location_name")
      weatherInfo.setValue(info.currentWeather, forKey: "weather_description")
      weatherInfo.setValue(info.icon, forKey: "icon")
      weatherInfo.setValue(info.currentTemp!, forKey: "current_temp")
      weatherInfo.setValue(0, forKey: "humidity")
      weatherInfo.setValue(0, forKey: "temp_min")
      weatherInfo.setValue(0, forKey: "temp_max")
      weatherInfo.setValue(info.sunrise, forKey: "sunrise")
      weatherInfo.setValue(info.sunset, forKey: "sunset")
      weatherInfo.setValue(info.dt, forKey: "dt")
      
      do {
         
         try context.save()
         
         print("Saved")
         sucess = true
         
      } catch {
         
         print("There was an error")
         
      }
      
      return sucess
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
   
}
