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
   func getExchangeRate(conversionInfo: ConversionInfo, completionHandler:@escaping (_ targetAmount: Double) -> Void ) {
      
      var sourceRate = 0.0
      var targetRate = 0.0
      
      let url = URL(string: "http://www.apilayer.net/api/live?access_key=" + APIKeys().getCurrencyAPIKey() + "&currencies=" + conversionInfo.sourceCurrency! + "," + conversionInfo.targetCurrency!)
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            print(error)
            
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
                  
                  DispatchQueue.main.sync(execute: {
                     
                     let targetAmount = self.convert(info: conversionInfo, sourceRate: sourceRate, targetRate: targetRate)
                     
                     completionHandler(targetAmount)
                     
                  })
                  
                  
               } catch {
                  
                  print("Error processing data")
                  
               }
               
            }
            
         }
         
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
