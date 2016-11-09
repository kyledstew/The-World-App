//
//  TranslationsData.swift
//  The World App
//
//  Created by Kyle Stewart on 11/9/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class TranslationsData: UIViewController {

   // SAVE TRANSLATION TO CORE DATA //
   func saveTranslation(info: TranslationInfo) -> Bool {
      
      var isSuccess = false
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let data = NSEntityDescription.insertNewObject(forEntityName: "Translations", into: context)
      
      let timestamp = Int(NSDate().timeIntervalSince1970 * 1000)
      
      data.setValue(timestamp, forKey: "timestamp")
      data.setValue(info.sourceLanguage, forKey: "source_language")
      data.setValue(info.targetLanguage, forKey: "target_language")
      data.setValue(info.textToTranslate, forKey: "text_to_translate")
      data.setValue(info.translatedText, forKey: "translated_text")
      
      do {
         
         try context.save()
         print("Saved")
         isSuccess = true
         
      } catch {
         
         print("Unable to save data")
         
      }
      
      return isSuccess
      
   }

   // LOAD TRANSLATSION FROM CORE DATA TO BE SHOWN IN TABLE //
   func loadTranslations() -> [Int: TranslationInfo] {
      
      var translations = [Int: TranslationInfo] ()
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Translations")
      
      request.returnsObjectsAsFaults = false
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               
               guard let timestamp = result.value(forKey: "timestamp") as? Int,
                  let sourceLanguage = result.value(forKey: "source_language") as? String,
                  let targetLanguage = result.value(forKey: "target_language") as? String,
                  let textToTranslate = result.value(forKey: "text_to_translate") as? String,
                  let translatedText = result.value(forKey: "translated_text") as? String
                  
                  else { continue }
               
               let temp = TranslationInfo(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage, sourceLanguageCode: nil, targetLanguageCode: nil, textToTranslate: textToTranslate, translatedText: translatedText)
               
               translations[timestamp] = temp
               
            }
            
         }
         
      } catch {
         
         print("Error loading past translations")
         
      }
      
      return translations
      
   }

   // DELETE DATA AT A CERTAIN TIMESTAMP //
   func deleteTranslation(timestamp: Int) {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Translations")
      
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

}
