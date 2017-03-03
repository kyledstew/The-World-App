//
//  Convert.swift
//  The World App
//
//  Created by Kyle Stewart on 11/5/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class Convert{

   // GET EXCHANGE RATE FOR SOURCE AND TARGET CURRENCIES//
   func getExchangeRate(conversionInfo: ConversionInfo, completionHandler:@escaping (_ targetAmount: Double, _ success: Bool, _ errorType: String, _ message: String) -> Void ) {
      
      var targetAmount = 0.0
      var success = false
      var errorType = "generic"
      var message = "An unknown error occurred. Please try again."
      
      var sourceRate = 0.0
      var targetRate = 0.0
      
      let url = URL(string: "http://www.apilayer.net/api/live?access_key=" + APIKeys().getCurrencyAPIKey() + "&currencies=" + conversionInfo.sourceCurrency! + "," + conversionInfo.targetCurrency!)
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            errorType = "connection_error"
            message = "Unable to download current exchange rates. Please make sure The World App has access to cellular data"
            print(error!)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  let currenciesArray = jsonResult["quotes"] as! [String: Double]
                  print(currenciesArray)
                  
                  for (currency, rate) in currenciesArray {
                     
                     if currency == "USD" + conversionInfo.sourceCurrency! {
                        
                        sourceRate = rate
                        
                     } else if currency == "USD" + conversionInfo.targetCurrency! {
                        
                        targetRate = rate
                        
                     } else {
                        
                        print("ERROR OCCURED!")
                        
                     }
                     
                  }
                  
                  targetAmount = self.convert(info: conversionInfo, sourceRate: sourceRate, targetRate: targetRate)
                  success = true
                  errorType = ""
                  message = ""
                  
               } catch {
                  
                  print("Error processing data")
                  
               }
               
            }
            
         }
         
         DispatchQueue.main.sync(execute: {
            
            completionHandler(targetAmount, success, errorType, message)
            
         })
         
      }
      task.resume()
      
   }
   
   // CONVERT //
   func convert(info: ConversionInfo, sourceRate: Double, targetRate: Double) -> Double {
      
      let sourceValueInDollars = (1/sourceRate) * info.sourceAmount!
      
      let targetAmountDouble = sourceValueInDollars * targetRate
      
      return targetAmountDouble
      
   }
   
   
}
