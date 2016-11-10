//
//  TranslatorViewController.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 9/30/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class TranslatorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
   // VARIABLES //
   var firstTime = true  // Used to download data the first time the open opens.
   var languages = [String: String] ()
   var sourceLanguageSelected = true
   var translations = [Int: TranslationInfo] ()
   
   // UI ITEMS //
   @IBOutlet var sourceLanguageButton: UIButton!
   @IBOutlet var targetLanguageButton: UIButton!
   @IBOutlet var textToTranslate: UITextView!
   @IBOutlet var translationLoader: UIActivityIndicatorView!
   @IBOutlet var translateButton: UIButton!
   @IBOutlet var loader: UIActivityIndicatorView!
   @IBOutlet var translationsTable: UITableView!
   // UI VIEWS
   @IBOutlet var sourceTargetLanguageView: UIView!
   @IBOutlet var textToTranslateView: UIView!
   
   // UI ITEM FUNCS //
   
   @IBAction func sourceLanguageButtonPressed(_ sender: AnyObject) {
      
      sourceLanguageSelected = true
      BlurVisualEffectViewController().enableBlur(temp: self)
      
   }
   
   @IBAction func targetLanguageButtonPressed(_ sender: AnyObject) {
      
      sourceLanguageSelected = false
      BlurVisualEffectViewController().enableBlur(temp: self)
      
   }
   
   @IBAction func switchButtonPressed(_ sender: AnyObject) {
      
      let newSourceLanguage = sourceLanguageButton.titleLabel?.text
      let newTargetLanguage = targetLanguageButton.titleLabel?.text
      
      sourceLanguageButton.setTitle(newTargetLanguage, for: .normal)
      targetLanguageButton.setTitle(newSourceLanguage, for: .normal)
      
      SelectedLanguageSettings().saveSelectedLanguageSettings(newSourceLanguage: newSourceLanguage!, newTargetLanguage: newTargetLanguage!)
      
      textToTranslate.text = ""
      
   }
   
   @IBAction func translateButtonPressed(_ sender: AnyObject) {
      
      if textToTranslate.text != "" {
         
         textToTranslate.isEditable = false
         translationLoader.startAnimating()
         translateButton.setTitle("", for: .normal)
         
         var info = TranslationInfo(sourceLanguage: sourceLanguageButton.currentTitle!, targetLanguage: targetLanguageButton.currentTitle!, sourceLanguageCode: LanguageSectionsData().getLanguageCode(languageName:sourceLanguageButton.currentTitle!), targetLanguageCode: LanguageSectionsData().getLanguageCode(languageName: targetLanguageButton.currentTitle!), textToTranslate: textToTranslate.text!, translatedText: nil)
         
         Translate().translateText(temp: &info, completionHandler: {
            
            self.translationLoader.stopAnimating()
            self.textToTranslate.isEditable = true
            self.textToTranslate.text = ""
            self.translateButton.setTitle("Translate", for: .normal)
            self.translations = TranslationsData().loadTranslations()
            self.translationsTable.reloadData()
            
         })
         
      }
      
   }
   
   func resetTranslationPage() {
      
      BlurVisualEffectViewController().disableBlur(temp: self)
      sourceLanguageButton.setTitle(SelectedLanguageSettings().getSourceLanguage(), for: .normal)
      targetLanguageButton.setTitle(SelectedLanguageSettings().getTargetLanguage(), for: .normal)
      
   }
   
   // VIEW DID LOAD //
   override func viewDidLoad() {
      super.viewDidLoad()
      
      sourceLanguageButton.setTitle(SelectedLanguageSettings().getSourceLanguage(), for: .normal)
      targetLanguageButton.setTitle(SelectedLanguageSettings().getTargetLanguage(), for: .normal)
      
      if (UserDefaults.standard.object(forKey: "isFirstTimeLoadingLanguages") as? Bool) == nil {
         
         loader.startAnimating()
         sourceLanguageButton.isHidden = true
         targetLanguageButton.isHidden = true
         
         LanguageDataAPI().getLanguagesList(completionHandler: {
            
            self.sourceLanguageButton.isHidden = false
            self.targetLanguageButton.isHidden = false
            self.loader.stopAnimating()
            
         })
         
      } else {
         
         translations = TranslationsData().loadTranslations()
         
      }
      
      NotificationCenter.default.addObserver(self, selector: #selector(TranslatorViewController.resetTranslationPage), name: NSNotification.Name(rawValue: "SelectLanguagePopupClosed"), object: nil)
      
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "toTargetLanguageSelector" {
         
         let selectLanguageViewController = segue.destination as! SelectLanguageViewController
         
         selectLanguageViewController.isSourceLanguage = false
         selectLanguageViewController.selectedLanguage = targetLanguageButton.currentTitle!
         
      } else if segue.identifier == "toSourceLanguageSelector" {
         
         let selectLanguageViewController = segue.destination as! SelectLanguageViewController
         
         selectLanguageViewController.isSourceLanguage = true
         selectLanguageViewController.selectedLanguage = sourceLanguageButton.currentTitle!
         
      }
      
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
         
         TranslationsData().deleteTranslation(timestamp: timestamp)
         translations[timestamp] = nil
         
         translationsTable.reloadData()
         
      }
      
   }
   
   // SORTFUNC - Sort greatest to least //
   func sortFunc(num1: Int, num2: Int) -> Bool {
      
      return num1 > num2
      
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
