//
//  AddNewWeatherLocationViewController.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 9/14/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class AddNewWeatherLocationViewController: UIViewController {
   
   // VARIABLES //
   
   var validLocation = false
   
   @IBOutlet var noResultsFoundMessage: UILabel!
   @IBOutlet var locationInput: UITextField!
   @IBOutlet var loader: UIActivityIndicatorView!
   
   @IBAction func cancelButton(_ sender: AnyObject) {
      
      self.dismiss(animated: true, completion: nil)
      
   }
   
   @IBAction func addButton(_ sender: AnyObject) {
      
      if locationInput.text != "" {
         
         loader.startAnimating()
         noResultsFoundMessage.isHidden = true
         getData(locationInput: locationInput.text!)
         
      }
      
   }
   override func viewDidLoad() {
      super.viewDidLoad()
      
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      
   }
   
   // Get Data for the location entered
   func getData(locationInput: String) {
      
      let encodedURL = locationInput.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed)
      
      let urlString = "http://api.openweathermap.org/data/2.5/weather?q=" + encodedURL! +  "&appid=58cfe76c601f5cfff47b22bc9cad0e1b&units=metric"
      
      let url = URL(string: urlString)
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            print(error)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  if (jsonResult["message"] as? String) != nil {
                     
                     print("Location not found")
                     
                  } else {
                     
                     if let locationName = jsonResult["name"] as? String {
                        
                        print(locationName + locationInput)
                        
                        if !self.dataExists(locationName: (locationName)) {
                           
                           if locationName == self.locationInput.text!.capitalized ||
                              locationName + " " == self.locationInput.text!.capitalized
                           
                           { // Sometimes the result is different then what we searched. Make sure it's the same!
                              
                              if let lon = jsonResult["coord"]?["lon"] as? Double {
                                 
                                 if let lat = jsonResult["coord"]?["lat"] as? Double {
                                    
                                    var weatherDescription = ""
                                    var icon = ""
                                    
                                    let weatherDescriptionArray = jsonResult["weather"] as! [[String: AnyObject]]
                                    
                                    for wda in weatherDescriptionArray {
                                       
                                       weatherDescription = wda["description"] as! String
                                       icon = wda["icon"] as! String
                                       
                                    }
                                    
                                    if let mainArray = jsonResult["main"] {
                                       
                                       self.validLocation = true
                                       
                                       let currentTemp = mainArray["temp"]!
                                       
                                       let humidity = mainArray["humidity"]!
                                       
                                       let tempMin = mainArray["temp_min"]!
                                       
                                       let tempMax = mainArray["temp_max"]
                                       
                                       let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                       let context = appDelegate.persistentContainer.viewContext
                                       let weatherInfo = NSEntityDescription.insertNewObject(forEntityName: "Weather", into: context)
                                       weatherInfo.setValue(locationName, forKey: "location_name")
                                       weatherInfo.setValue(lat, forKey: "lat")
                                       weatherInfo.setValue(lon, forKey: "lon")
                                       weatherInfo.setValue(weatherDescription, forKey: "weather_description")
                                       weatherInfo.setValue(icon, forKey: "icon")
                                       weatherInfo.setValue(currentTemp!, forKey: "current_temp")
                                       weatherInfo.setValue(humidity!, forKey: "humidity")
                                       weatherInfo.setValue(tempMin!, forKey: "temp_min")
                                       weatherInfo.setValue(tempMax!, forKey: "temp_max")
                                       
                                       do {
                                          
                                          try context.save()
                                          
                                          print("Saved")
                                          
                                       } catch {
                                          
                                          print("There was an error")
                                          
                                       }
                                       
                                       DispatchQueue.main.sync(execute: {
                                          self.dismiss(animated: true, completion: nil)
                                       })
                                       
                                    }
                                    
                                 }
                              }
                           }
                           
                        } else {    // DATA ALREADY EXISTS
                           
                           self.dismiss(animated: true, completion: nil)
                           
                        }
                        
                     }
                     
                  }
                  
                  DispatchQueue.main.sync(execute: {
                     
                     if !self.validLocation {
                        
                        self.loader.stopAnimating()
                        self.noResultsFoundMessage.isHidden = false
                        self.locationInput.text = ""
                        
                     }
                     
                  })
                  
               } catch {
                  print("Error processing failed")
               }
               
            }
            
         }
         
      }
      
      task.resume()
      
   }
   
   func dataExists(locationName: String) -> Bool {
      
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
   
   // Manage Keyboard, let the user exit
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      self.view.endEditing(true)
   }
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      
      return true
   }
   
   
   
}
