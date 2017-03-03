//
//  LanguageSectionsData.swift
//  The World App
//
//  Created by Kyle Stewart on 11/8/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class LanguageSectionsData {

   func loadLanguageList(searchText: String = "") -> [LanguageSection]
   {
      
      var sectionsArray = [LanguageSection] ()
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Languages_List")
      
      request.returnsObjectsAsFaults = false
      
      if searchText != "" {
         
         request.predicate = NSPredicate(format: "language_name contains[c] %@", searchText)
         
      }
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            var languages = [String: Int] ()
            var recentlyUsedLanguages = [String: Int] ()
            
            for result in results as! [NSManagedObject] {
               guard
                  let languageName = result.value(forKey: "language_name") as? String,
                  let recentlyUsed = result.value(forKey: "recently_used") as? Bool,
                  let timestampUsed = result.value(forKey: "timestamp_used") as? Int
               
                  else { continue }
               
               if recentlyUsed {
                  
                  recentlyUsedLanguages[languageName] = timestampUsed
                  
                  if recentlyUsedLanguages.count > 5 {
                     
                     let temp = getOldestLanguage(recentLanguages: &recentlyUsedLanguages)
                     languages[temp.language] = temp.timestampUsed
                     
                  }
                  
               } else {
                  
                  languages[languageName] = timestampUsed
                  
               }
               
               
            }
            
            let recentlyUsed = LanguageSection(title: "Recently Used", objects: recentlyUsedLanguages)
            let newLanguage = LanguageSection(title: "All Languages", objects: languages)
            
            sectionsArray.append(recentlyUsed)
            sectionsArray.append(newLanguage)
            
         }
         
      } catch {
         
         print("Error loading list of languages")
         
      }
      
      print("Languages loaded")
      
      return sectionsArray
      
   }
   
   func setRecentlyUsed(language: String, remove: Bool = false) {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Languages_List")
      
      request.returnsObjectsAsFaults = false
      request.predicate = NSPredicate(format: "language_name = %@", language)
      
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
   
   func getOldestLanguage(recentLanguages: inout [String: Int]) -> (language: String, timestampUsed: Int) {
      
      var languageToRemove: String?
      var timestampUsed: Int?
      
      for (language, timestamp) in recentLanguages {
         
         if language != SelectedLanguageSettings().getSourceLanguage() && language != SelectedLanguageSettings().getTargetLanguage() {
            
            if timestampUsed != nil {
               
               if timestamp < (timestampUsed)! {
                  
                  timestampUsed = timestamp
                  languageToRemove = language
                  
               }
               
            } else {
               
               timestampUsed = timestamp
               languageToRemove = language
               
            }
         }
         
      }
      
      setRecentlyUsed(language: languageToRemove!, remove: true)
      recentLanguages[languageToRemove!] = nil
      
      return (languageToRemove!, timestampUsed!)
      
   }

   func getLanguageCode(languageName: String) -> String {

      var languageCode = ""
         
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Languages_List")
      
      request.returnsObjectsAsFaults = false
      request.predicate = NSPredicate(format: "language_name = %@", languageName)
      
      do {
         
         let results = try context.fetch(request)

         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               guard
                  let temp = result.value(forKey: "language_code") as? String
                  else { continue }
               
               languageCode = temp
            }
            
         }
         
      } catch {
         
         print("No Results")
      }
      
      return languageCode
      
   }

}
