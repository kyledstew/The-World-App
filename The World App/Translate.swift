//
//  Translate.swift
//  The World App
//
//  Created by Kyle Stewart on 11/9/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class Translate {

   // GET TRANSLATION FOR INPUT TEXT //
   func translateText(temp: inout TranslationInfo, completionHandler:@escaping () -> Void ) {
      
      var info = temp
      
      if let textToTranslateEncoded = info.textToTranslate?.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed) {

         
         let urlString = "https://www.googleapis.com/language/translate/v2?key=" + APIKeys().getGoogleTranslatorAPIKey() + "&q=" + textToTranslateEncoded + "&source=" + info.sourceLanguageCode! + "&target=" + info.targetLanguageCode!
         
         print(urlString)
         
         let url = URL(string: urlString)
         
         let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
               
               print(error)
               
            } else {
               
               if let urlContent = data {
                  
                  do {
                     
                     let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                     
                     if let translationDictionary = jsonResult["data"] as? NSDictionary {
                        
                        if let translationsArray = translationDictionary["translations"] as? [[String: String]]{
                           
                           print(translationsArray)
                        
                           info.translatedText = translationsArray[0]["translatedText"]!
                           
                           print(info.translatedText!)
                           
                        }
                        
                     }
                     
                     DispatchQueue.main.sync(execute: {
                        
                        if TranslationsData().saveTranslation(info: info) {
                           
                           completionHandler()
                           
                        }
                        
                     })
                     
                  } catch {
                     
                     print("Error processing data")
                     
                  }
               }
            }
         }
         task.resume()
 
      }
      
   }


}
