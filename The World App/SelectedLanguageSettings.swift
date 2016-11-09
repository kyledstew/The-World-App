//
//  SelectedLanguageSettings.swift
//  The World App
//
//  Created by Kyle Stewart on 11/8/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class SelectedLanguageSettings {

   func getSourceLanguage() -> String {
      
      var sourceLanguage: String?
      
      if let temp = UserDefaults.standard.object(forKey: "sourceLanguage") as? String {
         
         sourceLanguage = temp
         
      } else {
         
         sourceLanguage = "English"
         UserDefaults.standard.set("English", forKey: "sourceLanguage")
         
      }
      
      return sourceLanguage!
      
   }
   
   func getTargetLanguage() -> String {
      
      var targetLanguage: String?
      
      if let temp = UserDefaults.standard.object(forKey: "targetLanguage") as? String {
         
         targetLanguage = temp
         
      } else {
         
         targetLanguage = "Japanese"
         UserDefaults.standard.set("Japanese", forKey: "targetLanguage")
         
      }
      
      return targetLanguage!
      
   }
   
   // SAVE TABLE SETTINGS TO PERMANANT MEMORY //
   func saveSelectedLanguageSettings(newSourceLanguage: String = "", newTargetLanguage: String = "") {
      
      if newSourceLanguage != "" {
      
         UserDefaults.standard.set(newSourceLanguage, forKey: "sourceLanguage")
      
      } else if newTargetLanguage != "" {
      
         UserDefaults.standard.set(newTargetLanguage, forKey: "targetLanguage")
         
      }
      
   }

}
