//
//  CurrencyData.swift
//  The World App
//
//  Created by Kyle Stewart on 10/27/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class CurrencyData {
   
   // GET LIST OF CURRENCIES FROM API - ONLY USED FIRST TIME APP RUNS //
   func getCurrencyList(completionHandler:@escaping () -> Void ) {
      
      var currencies = [String: String] ()
      
      let url = URL(string: "http://www.apilayer.net/api/list?access_key=" + APIKeys().getCurrencyAPIKey())
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            print(error)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  var numberOfCurrencies = 0
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  let currenciesArray = jsonResult["currencies"] as! [String: String]
                  
                  for (abbreviation, currency) in currenciesArray {
                     
                     currencies[abbreviation] = currency
                     numberOfCurrencies += 1
                     
                  }
                  
                  
                  DispatchQueue.main.sync(execute: {
                     
                     if self.saveToCoreData(currencies: currencies) {
                        
                        UserDefaults.standard.set(false, forKey: "isFirstTimeLoadingCurrencies")
                        completionHandler()
                        
                     } else {
                        
                        print("ERROR SAVING DATA")
                        
                     }
                     
                  })
                  
                  
               } catch {
                  
                  print("Error processing data")
                  
               }
               
            }
            
         }
         
      }
      task.resume()
      
   }
   
   // SAVE LIST OF CURRENCIES TO CORE DATA //
   func saveToCoreData(currencies: [String: String]) -> Bool {
      
      var isSuccess = false
      
      var numberOfCurrencies = 0
      
      for (abbreviation, currency) in currencies {
         
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let context = appDelegate.persistentContainer.viewContext
         let data = NSEntityDescription.insertNewObject(forEntityName: "Currency_List", into: context)
         
         data.setValue(abbreviation, forKey: "abbreviation")
         data.setValue(currency, forKey: "currency")
         
         if abbreviation == "USD" || abbreviation == "JPY" {
            
            data.setValue(true, forKey: "recently_used")
            data.setValue(Int(NSDate().timeIntervalSince1970), forKey: "timestamp_used")
            
         } else {
            
            data.setValue(false, forKey: "recently_used")
            data.setValue(0, forKey: "timestamp_used")
            
         }
         
         do {
            try context.save()
            isSuccess = true
            numberOfCurrencies += 1
            
         } catch {
            
            print("There was an error " + currency)
            
         }
      }
      
      print("\(numberOfCurrencies) currencies saved")
      
      return isSuccess
      
   }
   
}
