//
//  CurrencyDataAPI.swift
//  The World App
//
//  Created by Kyle Stewart on 10/27/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class CurrencyDataAPI {
   
   // GET LIST OF CURRENCIES FROM API - ONLY USED FIRST TIME APP RUNS //
   func getCurrencyList(completionHandler:@escaping (_ success: Bool, _ errorType: String, _ message: String) -> Void ) {
      
      var success = false
      var errorType = "generic"
      var message = "An unkown error occurred. Please try again."
      
      var currencies = [String: String] ()
      
      let url = URL(string: "http://www.apilayer.net/api/list?access_key=" + APIKeys().getCurrencyAPIKey())
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            errorType = "connection_error"
            message = "Unable to download currency data. Please make sure The World App has access to cellular data"
            
            print(error!)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  let currenciesArray = jsonResult["currencies"] as! [String: String]
                  
                  for (abbreviation, currency) in currenciesArray {
                     
                     currencies[abbreviation] = currency
                     
                  }
                  
               } catch {
                  
                  print("Error processing data")
                  
               }
               
            }
            
         }
         
         DispatchQueue.main.sync(execute: {
            
            if self.saveToCoreData(currencies: currencies) {
               
               success = true
               errorType = ""
               message = ""
               UserDefaults.standard.set(false, forKey: "isFirstTimeLoadingCurrencies")
               
            } else {
               
               message = "An error occurred when saving Data. Please try again."
               
            }
            
            completionHandler(success, errorType, message)
            
         })
         
      }
      task.resume()
      
   }
   
   // SAVE LIST OF CURRENCIES TO CORE DATA //
   func saveToCoreData(currencies: [String: String]) -> Bool {
      
      var isSuccess = false
      
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
            
         } catch {
            
            print("There was an error " + currency)
            
         }
      }
      
      return isSuccess
      
   }
   
}
