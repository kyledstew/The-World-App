//
//  SelectedCurrencySettings.swift
//  The World App
//
//  Created by Kyle Stewart on 11/6/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class SelectedCurrencySettings {

   func getSourceCurrency() -> String {
      
      var sourceCurrency: String?
      
      if let temp = UserDefaults.standard.object(forKey: "sourceCurrency") as? String {
         
         sourceCurrency = temp
         
      } else { // If first time using, set source default to USD
         
         sourceCurrency = "USD"
         UserDefaults.standard.set("USD", forKey: "sourceCurrency")
         
      }

      return sourceCurrency!

   }
   
   func getTargetCurrency() -> String {
      
      var targetCurrency: String?
      
      if let temp = UserDefaults.standard.object(forKey: "targetCurrency") as? String {
         
         targetCurrency = temp
         
      } else { // If first time using, set target default to JPY
         
         targetCurrency = "JPY"
         UserDefaults.standard.set("JPY", forKey: "targetCurrency")
         
      }
      
      return targetCurrency!
      
   }
   
   // SAVE TABLE SETTINGS TO PERMANANT MEMORY //
   func saveSelectedCurrencySettings(newSourceCurrency: String = "", newTargetCurrency: String = "") {
      
      if newSourceCurrency != "" {
         
         UserDefaults.standard.set(newSourceCurrency, forKey: "sourceCurrency")
      
      }
      
      if newTargetCurrency != "" {
         
         UserDefaults.standard.set(newTargetCurrency, forKey: "targetCurrency")
         
      }
      
   }

}
