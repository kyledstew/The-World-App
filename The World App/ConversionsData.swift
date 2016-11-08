//
//  ConversionsData.swift
//  The World App
//
//  Created by Kyle Stewart on 10/27/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class ConversionsData {
   
   // SAVE CONVERSION TO CORE DATA //
   func saveConversion(sourceAmount: Double, sourceCurrency: String, targetAmount: Double, targetCurrency: String) -> Bool {
      
      var isSuccess = false

      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let conversionInfo = NSEntityDescription.insertNewObject(forEntityName: "Currency_Conversions", into: context)
      
      let timestamp = Int(NSDate().timeIntervalSince1970 * 1000)
      
      conversionInfo.setValue(timestamp, forKey: "timestamp")
      conversionInfo.setValue(sourceAmount, forKey: "source_amount")
      conversionInfo.setValue(sourceCurrency, forKey: "source_currency")
      conversionInfo.setValue(targetAmount, forKey: "target_amount")
      conversionInfo.setValue(targetCurrency, forKey: "target_currency")
      
      do {
         
         try context.save()
         print("Saved")
         isSuccess = true
         
      } catch {
         
         print("ERROR SAVING DATA")
         
      }
      
      return isSuccess
      
   }
   
   // LOAD CONVERSION FROM CORE DATA TO BE SHOWN IN TABLE //
   func loadConversions() -> [Int: ConversionInfo]{
      
      var conversions = [Int: ConversionInfo] ()
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Currency_Conversions")
      
      request.returnsObjectsAsFaults = false
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               
               guard let timestamp = result.value(forKey: "timestamp") as? Int,
                  let sourceAmount = result.value(forKey: "source_amount") as? Double,
                  let sourceCurrency = result.value(forKey: "source_currency") as? String,
                  let targetAmount = result.value(forKey: "target_amount") as? Double,
                  let targetCurrency = result.value(forKey: "target_currency") as? String
                  
                  else {continue}
               
               let temp = ConversionInfo(sourceAmount: sourceAmount, sourceCurrency: sourceCurrency, targetAmount: targetAmount, targetCurrency: targetCurrency)
               
               conversions[timestamp] = temp
               
               
            }
            
      }
         
      } catch {
         
         print("Error loading past conversions")
         
      }
      
      //test.conversionsTable.reloadData()
      return conversions
      
   }
   
   // DELETE DATA AT A CERTAIN TIMESTAMP //
   func deleteConversion(timestamp: Int) {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Currency_Conversions")
      
      request.predicate = NSPredicate(format: "timestamp == \(timestamp)")
      
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

   func refreshConversions(conversions: [Int: ConversionInfo], completeHandler: @escaping () -> Void) {
      
      for (timestamp, info) in conversions {
         
         var newData = ConversionInfo(sourceAmount: info.sourceAmount, sourceCurrency: info.sourceCurrency, targetAmount: nil, targetCurrency: info.targetCurrency)
         
         Convert().getExchangeRate(conversionInfo: newData, completionHandler: {(newTargetAmount:Double) in
         
            newData.targetAmount = newTargetAmount
            self.updateCoreData(conversion: newData, timestamp: timestamp)
            completeHandler()
         
         })
         
      }
      
      
   }
   
   func updateCoreData(conversion: ConversionInfo, timestamp: Int) {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Currency_Conversions")
      
      request.predicate = NSPredicate(format: "timestamp == \(timestamp)")
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               
               result.setValue(conversion.targetAmount, forKey: "target_amount")
               
               do {
                  
                  try context.save()
                  print("DATA REFRESHED")
                  
               } catch {
                  
                  print("Unable to save updated conversion")
                  
               }
               
            }
            
         }
         
      } catch {
         
         print("Error precessing failed")
         
      }
      
      
      
   }
   
}
