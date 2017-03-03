//
//  CurrencySectionsData.swift
//  The World App
//
//  Created by Kyle Stewart on 10/20/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class CurrencySectionsData {
   
   // LOAD ALL THE CURRENCIES FROM CORE DATA //
   func loadCurrencyList(searchText: String = "") -> [CurrencySection] {
      
      var sectionsArray = [CurrencySection] ()
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Currency_List")
      
      request.returnsObjectsAsFaults = false
      
      if searchText != "" {
         
         request.predicate = NSPredicate(format: "currency contains[c] %@ OR abbreviation contains[c] %@", searchText, searchText)
         
      }
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            var currencies = [String: CurrencyInfo] ()
            var recentlyUsedCurrencies = [String: CurrencyInfo] ()
            
            for result in results as! [NSManagedObject] {
               guard
                  let abbreviation = result.value(forKey: "abbreviation") as? String,
                  let currency = result.value(forKey: "currency") as? String,
                  let recentlyUsed = result.value(forKey: "recently_used") as? Bool,
                  let timestampUsed = result.value(forKey: "timestamp_used") as? Int
               
                  else {continue}
               
               if recentlyUsed {
         
                  let temp = CurrencyInfo(curr: currency, time: timestampUsed)
                  
                  recentlyUsedCurrencies[abbreviation] = temp
                  
                  if recentlyUsedCurrencies.count > 5 {
                     
                     let temp = getOldestCurrency(recentCurrencies: &recentlyUsedCurrencies)
                     currencies[temp.currency] = temp.info
                     
                  }
                  
               } else {

                  
               let temp = CurrencyInfo(curr: currency)
                  
               currencies[abbreviation] = temp
               
               }
               
            }
            
            let recentlyUsed = CurrencySection(title: "Recently Used", objects: recentlyUsedCurrencies)
            let newCurrency = CurrencySection(title: "All Currencies", objects: currencies)
            
            sectionsArray.append(recentlyUsed)
            sectionsArray.append(newCurrency)
            
         }
         
      } catch {
         
         print("Error loading list of currencies")
         
      }
      
      return sectionsArray
      
   }
   
   
   func setRecentlyUsed(currency: String, remove: Bool = false) {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Currency_List")
      
      request.returnsObjectsAsFaults = false
      request.predicate = NSPredicate(format: "abbreviation = %@", currency)
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               
               if !remove {
                  
                  result.setValue(true, forKey: "recently_used")
                  result.setValue(Int64(NSDate().timeIntervalSince1970), forKey: "timestamp_used")
                  
               } else {
                  
                  result.setValue(false, forKey: "recently_used")
                  result.setValue(0, forKey: "timestamp_used")
                  
               }
               
               do {
                  
                  try context.save()
                  
               } catch {
                  
                  print("There was an error saving")
                  
               }
               
            }
            
         }
         
      } catch {
         
         print("No Results")
         
      }
      
   }
   
   func getOldestCurrency(recentCurrencies: inout [String: CurrencyInfo]) -> (currency: String, info: CurrencyInfo) {
      
      var currencyToRemove: String?
      var currencyInfo: CurrencyInfo?
      
      for (abbreviation, info) in recentCurrencies {
       
         if abbreviation != SelectedCurrencySettings().getSourceCurrency() && abbreviation != SelectedCurrencySettings().getTargetCurrency() {
         
            if currencyInfo != nil {
            
               if info.timestamp < (currencyInfo?.timestamp)! {
               
                  currencyInfo = info
                  currencyToRemove = abbreviation
               
               }
            
            } else {
            
               currencyInfo = info
               currencyToRemove = abbreviation
               
            }
         }
         
      }

      setRecentlyUsed(currency: currencyToRemove!, remove: true)
      recentCurrencies[currencyToRemove!] = nil
   
      return(currencyToRemove!, currencyInfo!)
      
   }
}
