//
//  TranslatorViewController.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 9/30/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class TranslatorViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDelegate, UITableViewDataSource {
   
   // VARIABLES //
   var firstTime = true  // Used to download data the first time the open opens.
   var languages = [String: String] ()
   var sourceLanguageSelected = true
   let key = "AIzaSyAWDvyP9k99oqCoS-w5rIpmIuemRZEajag" // API Code
   struct TranslationInfo {
      var sourceLanguage: String?
      var targetLanguage: String?
      var textToTranslate: String?
      var translatedText: String?
   }
   var translations = [Int: TranslationInfo] ()
   
   // UI ITEMS //
   @IBOutlet var sourceLanguageButton: UIButton!
   @IBOutlet var targetLanguageButton: UIButton!
   @IBOutlet var selectLanguagePrompt: UILabel!
   @IBOutlet var languagePicker: UIPickerView!
   @IBOutlet var textToTranslate: UITextView!
   @IBOutlet var translationLoader: UIActivityIndicatorView!
   @IBOutlet var translationsTable: UITableView!
   // UI VIEWS
   @IBOutlet var sourceTargetLanguageView: UIView!
   @IBOutlet var textToTranslateView: UIView!
   @IBOutlet var selectLanguageView: UIView!
   
   // UI ITEM FUNCS //
   
   @IBAction func sourceLanguageButtonPressed(_ sender: AnyObject) {
      
      sourceLanguageSelected = true
      
      if languages.count > 0 {
         languagePicker.selectRow(Array(languages.keys).sorted().index(of: sourceLanguageButton.titleLabel!.text!)!, inComponent: 0, animated: false)
         selectLanguageView.isHidden = false
         selectLanguagePrompt.text = "Select Source Language"
      }
      
   }
   
   @IBAction func targetLanguageButtonPressed(_ sender: AnyObject) {
      
      sourceLanguageSelected = false
      
      if languages.count > 0 {
         languagePicker.selectRow(Array(languages.keys).sorted().index(of: targetLanguageButton.titleLabel!.text!)!, inComponent: 0, animated: false)
         selectLanguagePrompt.text = "Select Target Language"
         selectLanguageView.isHidden = false
      }
      
   }
   
   @IBAction func switchButtonPressed(_ sender: AnyObject) {
      
      let sourceLanguage = sourceLanguageButton.titleLabel?.text
      let targetLanguage = targetLanguageButton.titleLabel?.text
      
      sourceLanguageButton.setTitle(targetLanguage, for: .normal)
      targetLanguageButton.setTitle(sourceLanguage, for: .normal)
      
      saveSelectedLanguageSettings(newSourceLanguage: targetLanguage!, newTargetLanguage: sourceLanguage!)
      
   }
   
   @IBAction func selectLanguageButton(_ sender: AnyObject) {
      
      if sourceLanguageSelected {
         
         let selectedLanguage = Array(languages.keys).sorted()[languagePicker.selectedRow(inComponent: 0)]
         
         sourceLanguageButton.setTitle(selectedLanguage, for: .normal)
         
         saveSelectedLanguageSettings(newSourceLanguage: selectedLanguage)
         
         print(selectedLanguage + " as source")
         
         
      } else {
         
         let selectedLanguage = Array(languages.keys).sorted()[languagePicker.selectedRow(inComponent: 0)]
         
         targetLanguageButton.setTitle(selectedLanguage, for: .normal)
         
         saveSelectedLanguageSettings(newTargetLanguage: selectedLanguage)
         
         print(selectedLanguage + " as target")
         
      }
      
      selectLanguageView.isHidden = true
      
   }
   @IBAction func translateButtonPressed(_ sender: AnyObject) {
      
      if textToTranslate.text != "" {
         
         textToTranslate.isEditable = false
         translationLoader.startAnimating()
         
         translateText(sourceLanguage: (sourceLanguageButton.titleLabel?.text)!, targetLanguage: (targetLanguageButton.titleLabel?.text)!, textToTranslate: textToTranslate.text!)
         
      }
      
   }
   
   // VIEW DID LOAD //
   override func viewDidLoad() {
      super.viewDidLoad()
      
      
      if (UserDefaults.standard.object(forKey: "firstTimeLoadingLanguages") as? Bool) == nil {
         
         translationLoader.startAnimating()
         getLanguagesList()
         
      } else {
         
         loadLanguageList()
         loadTranslations()
         
      }
      
      if let sourceLanguage = UserDefaults.standard.object(forKey: "sourceLanguage") as? String {
         
         print(sourceLanguage)
         sourceLanguageButton.setTitle(sourceLanguage, for: .normal)
         
      }
      
      if let targetLanguage = UserDefaults.standard.object(forKey: "targetLanguage") as? String {
         
         targetLanguageButton.setTitle(targetLanguage, for: .normal)
         
      }
      
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      
      
   }
   
   /***************************************************************/
   //               !!!PICKER FUNCTIONS!!!
   /***************************************************************/
   public func numberOfComponents(in pickerView: UIPickerView) -> Int {
      
      return 1
      
   }
   
   public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      
      return languages.count
      
   }
   
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      
      var langArray = Array(languages.keys).sorted()
      
      return langArray[row]
      
   }
   
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      
      var langArray = Array(languages.keys).sorted()
      print(languages[langArray[row]]!)
      
   }
   
   /***************************************************************/
   //               !!!TABLE FUNCTIONS!!!
   /***************************************************************/
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      return  translations.count
      
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "TranslationsTableViewCell", for: indexPath) as! TranslationsTableViewCell
      
      var array = Array(translations.keys).sorted(by: sortFunc)
      
      let current = translations[array[indexPath.row]]
      
      cell.sourceLanguageLabel.text = current?.sourceLanguage
      cell.targetLanguageLabel.text = current?.targetLanguage
      cell.textToTranslateLabel.text = current?.textToTranslate
      cell.translatedTextLabel.text = current?.translatedText
 
      return cell
      
   }
   
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == UITableViewCellEditingStyle.delete {
         
         let timestamp = Array(translations.keys).sorted(by: sortFunc)[indexPath.row]
         
         deleteData(timestamp: timestamp)
         translations[timestamp] = nil
         
         translationsTable.reloadData()
         
      }
      
   }
   
   // SORTFUNC - Sort greatest to least //
   func sortFunc(num1: Int, num2: Int) -> Bool {
      
      return num1 > num2
      
   }
   
   // SAVE PICKER SETTINGS TO PERMANANT MEMORY //
   func saveSelectedLanguageSettings(newSourceLanguage: String = "NoChange", newTargetLanguage: String = "NoChange") {
      
      if newSourceLanguage != "NoChange" {
         UserDefaults.standard.set(newSourceLanguage, forKey: "sourceLanguage")
      }
      
      if newTargetLanguage != "NoChange" {
         UserDefaults.standard.set(newTargetLanguage, forKey: "targetLanguage")
      }
      
   }
   
   // GET LIST OF LANGUAGES FROM API - ONLY USED FIRST TIME APP RUNS //
   func getLanguagesList() {
      
      let url = URL(string: "https://www.googleapis.com/language/translate/v2/languages?key=" + key + "&target=en")
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            print(error)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  var numberOfLanguages = 0
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
 
                  if let temp = jsonResult["data"]?["languages"] as? [[String: String]]
                  {
                     
                     for data in temp {
                        
                        if let languageAbbr = data["language"] {
                           
                           if let languageName = data["name"] {
                              
                              self.languages[languageAbbr] = languageName
                              numberOfLanguages += 1
                              
                           }
                           
                        }
                        
                     }
                     
                     DispatchQueue.main.sync(execute: {
                        
                        print("\(numberOfLanguages) languages saved")
                        if self.saveToCoreData() {
                           self.firstTime = false
                           UserDefaults.standard.set(self.firstTime, forKey: "firstTimeLoadingLanguages")
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
   func saveToCoreData() -> Bool {
      
      var isSuccess = false
      
      var numberOfLanguages = 0
      
      for (languageAbbr, languageName) in languages {
      
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let context = appDelegate.persistentContainer.viewContext
         let data = NSEntityDescription.insertNewObject(forEntityName: "Languages_List", into: context)
      
      
         data.setValue(languageAbbr, forKey: "language_abbr")
         data.setValue(languageName, forKey: "language_name")
      
         do {
            try context.save()
            isSuccess = true
            numberOfLanguages += 1
         
         } catch {
         
            print("There was an error " + languageName)
         
         }
      }
      loadLanguageList()
      
      return isSuccess
      
   }
   
   // LOAD ALL THE LANGUAGES FROM CORE DATA //
   func loadLanguageList() {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Languages_List")
      
      request.returnsObjectsAsFaults = false
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               guard let languageAbbr = result.value(forKey: "language_abbr") as? String,
                     let languageName = result.value(forKey: "language_name") as? String
                  
                  else { continue }
               
             languages[languageName] = languageAbbr
             }
            
            
         }
         
      } catch {
         
         print("Error loading list of languages")
         
      }
      
      print("Languages loaded")
      
      translationLoader.stopAnimating()
      languagePicker.reloadAllComponents()
      
   }
   
   // LOAD TRANSLATSION FROM CORE DATA TO BE SHOWN IN TABLE //
   func loadTranslations() {
      
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
               
                  let temp = TranslationInfo(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage, textToTranslate: textToTranslate, translatedText: translatedText)
                              
                  translations[timestamp] = temp
               
            }
            
            translationsTable.reloadData()
            
         }
         
      } catch {
         
         print("Error loading past translations")
         
      }
      
   }
   
   // GET TRANSLATION FOR INPUT TEXT //
   func translateText(sourceLanguage: String, targetLanguage: String, textToTranslate: String) {
      
      if let textToTranslateEncoded = textToTranslate.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlFragmentAllowed) {
         
         let sourceLanguageCode = languages[sourceLanguage]! as String
         let targetLanguageCode = languages[targetLanguage]! as String
         
         let urlString = "https://www.googleapis.com/language/translate/v2?key=" + key + "&q=" + textToTranslateEncoded + "&source=" + sourceLanguageCode + "&target=" + targetLanguageCode
         
         let url = URL(string: urlString)
         
         let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
               
               print(error)
               
            } else {
               
               if let urlContent = data {
                  
                  var translatedText = ""
                  
                  do {
                     
                     let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                     
                     if let translationDictionary = jsonResult["data"] as? NSDictionary {
                        
                        if let translationsArray = translationDictionary["translations"] as? [[String: String]]{
                           
                           translatedText = translationsArray[0]["translatedText"]!
                           
                        }
                        
                     }
                     
                     DispatchQueue.main.sync(execute: {
                        
                        if self.saveTranslations(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage, textToTranslate: textToTranslate, translatedText: translatedText) {
                           
                           self.textToTranslate.text = ""
                           self.textToTranslate.isEditable = true
                           self.translationLoader.stopAnimating()
                           
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
   
   // SAVE TRANSLATION TO CORE DATA //
   func saveTranslations(sourceLanguage: String, targetLanguage: String, textToTranslate: String, translatedText: String) -> Bool {
      
      var isSuccess = false
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let data = NSEntityDescription.insertNewObject(forEntityName: "Translations", into: context)
      
      let timestamp = Int(NSDate().timeIntervalSince1970 * 1000)
      
      data.setValue(timestamp, forKey: "timestamp")
      data.setValue(sourceLanguage, forKey: "source_language")
      data.setValue(targetLanguage, forKey: "target_language")
      data.setValue(textToTranslate, forKey: "text_to_translate")
      data.setValue(translatedText, forKey: "translated_text")
      
      do {
         
         try context.save()
         print("Saved")
         loadTranslations()
         isSuccess = true
         
      } catch {
         
         print("Unable to save data")
         
      }
      
      return isSuccess
      
   }
   
   // DELETE DATA AT A CERTAIN TIMESTAMP //
   func deleteData(timestamp: Int) {
      
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
   
   // MANAGES KEYBOARD, LETS THE USER CLOSE IT //
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      self.view.endEditing(true)
   }
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      
      return true
   }
   
}
