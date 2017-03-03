//
//  LanguageDataAPI.swift
//  The World App
//
//  Created by Kyle Stewart on 11/9/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class LanguageDataAPI {

   // GET LIST OF LANGUAGES FROM API - ONLY USED FIRST TIME APP RUNS //
   func getLanguagesList(completionHandler:@escaping () -> Void ) {
      
      var languages = [String: String] ()
      
      let url = URL(string: "https://www.googleapis.com/language/translate/v2/languages?key=" + APIKeys().getGoogleTranslatorAPIKey() + "&target=en")
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            print(error)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  if let temp = jsonResult["data"]?["languages"] as? [[String: String]]
                  {
                     
                     for data in temp {
                        
                        if let languageCode = data["language"] {
                           
                           if let languageName = data["name"] {
                              
                              languages[languageCode] = languageName
                              
                           }
                           
                        }
                        
                     }
                     
                     DispatchQueue.main.sync(execute: {
                        
                        if self.saveToCoreData(languages: languages) {
                           
                           UserDefaults.standard.set(false, forKey: "isFirstTimeLoadingLanguages")
                           completionHandler()
                           
                        } else {
                           
                           print("ERROR SAVING DATA")
                           
                        }
                        
                     })
                     
                  }
                  
               } catch {
                  
                  print("No Data")
                  
               }
               
            }
            
         }
      }
      task.resume()
      
   }
   
   // SAVE LIST OF LANGUAGES TO CORE DATA //
   func saveToCoreData(languages: [String: String]) -> Bool {
      
      var isSuccess = false
      
      for (languageCode, languageName) in languages {
         
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let context = appDelegate.persistentContainer.viewContext
         let data = NSEntityDescription.insertNewObject(forEntityName: "Languages_List", into: context)
         
         
         data.setValue(languageCode, forKey: "language_code")
         data.setValue(languageName, forKey: "language_name")
         
         if languageName == "English" || languageName == "Japanese" {
            
            data.setValue(true, forKey: "recently_used")
            data.setValue(Int64(NSDate().timeIntervalSince1970), forKey: "Timestamp_used")
            
         } else {
            
            data.setValue(false, forKey: "recently_used")
            data.setValue(0, forKey: "Timestamp_used")
            
         }
         
         do {
            try context.save()
            isSuccess = true
            
         } catch {
            
            print("There was an error " + languageName)
            
         }
      }
      
      return isSuccess
   }

}
