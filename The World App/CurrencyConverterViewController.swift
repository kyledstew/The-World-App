//
//  CurrencyConverterViewController.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 9/20/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class CurrencyConverterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
   // VARIABLES //
   var isFirstTime = true
   let key = "a813f08491bba38f9ed22bf31c3ecd54"
   var currencies = [String: String] ()
   var sourceCurrencySelected = true
   struct ConversionInfo {
      
      var sourceAmount: Double?
      var sourceCurrency: String?
      var targetAmount: Double?
      var targetCurrency: String?
      
   }
   var conversions = [Int: ConversionInfo] ()
   var isSourceCurrency = true // keep track of which currency changed
   var blurredScreen = BlurVisualEffectViewController()
   
   // UI ITEMS //
   @IBOutlet var sourceCurrencyButton: UIButton!
   @IBOutlet var targetCurrencyButton: UIButton!
   @IBOutlet var loader: UIActivityIndicatorView!
   @IBOutlet var switchButton: UIButton!
   @IBOutlet var targetAmountLoader: UIActivityIndicatorView!
   @IBOutlet var sourceAmount: UITextField!
   @IBOutlet var targetAmount: UITextField!
   @IBOutlet var toArrow: UIButton!
   @IBOutlet var clickSaveConversionPrompt: UIView!
   @IBOutlet var conversionsTable: UITableView!
   
   // UI VIEWS //
   @IBOutlet var currencyConversionView: UIView!
   @IBOutlet var loaderView: UIView!
   
   public func isSourceCurrencySelected() -> Bool {
      
      return sourceCurrencySelected
      
   }
   
   // UI ITEM FUNCS //
   @IBAction func sourceCurrencyButtonPressed(_ sender: AnyObject) {
      
      sourceCurrencySelected = true
      blurredScreen.enableBlur(temp: self)
      
      
   }
   
   func resetConversionPage() {
      
      blurredScreen.disableBlur(temp: self)
      loadSelectedCurrencySettings()
      
   }
   
   @IBAction func targetCurrencyButtonPressed(_ sender: AnyObject) {
      
      sourceCurrencySelected = false
      blurredScreen.enableBlur(temp: self)
      
   }
   
   @IBAction func switchButtonPressed(_ sender: AnyObject) {
      
      let newTargetCurrency = sourceCurrencyButton.titleLabel?.text
      let newSourceCurrency = targetCurrencyButton.titleLabel?.text
      
      sourceCurrencyButton.setTitle(newSourceCurrency, for: .normal)
      targetCurrencyButton.setTitle(newTargetCurrency, for: .normal)
      
      saveSelectedCurrencySettings(newSourceCurrency:  newSourceCurrency!, newTargetCurrency: newTargetCurrency!)
      
      if sourceAmount.text != "" && Double(sourceAmount.text!) != nil {
         
         targetAmount.text = ""
         getExchangeRate()
         
      }
   }
   
   @IBAction func sourceAmountValueChanged(_ sender: AnyObject) {
      
      if sourceAmount.text == "" {
         
         targetAmount.text = ""
         
      } else if Double(sourceAmount.text!) != nil {
         
         targetAmountLoader.startAnimating()
         getExchangeRate()
         
         
      } else {
         
         print("Not double....")
         targetAmount.text = ""
         
      }
      
   }
   
   @IBAction func saveConversion(_ sender: AnyObject) {
      
      if sourceAmount.text != "" && Double(sourceAmount.text!) != nil {
         
         if saveConversion(sourceAmount: Double(sourceAmount.text!)!, sourceCurrency: sourceCurrencyButton.currentTitle!, targetAmount: Double(targetAmount.text!)!, targetCurrency: targetCurrencyButton.currentTitle!) {
            
            print("Saved Successfully")
            
         }
      }
      
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "toTargetCurrencySelector" {

         let selectCurrencyViewController = segue.destination as! SelectCurrencyViewController
         
         selectCurrencyViewController.isSourceCurrency = false
         selectCurrencyViewController.selectedCurrency = targetCurrencyButton.currentTitle!
         
      } else if segue.identifier == "toSourceCurrencySelector" {
         
         let selectCurrencyViewController = segue.destination as! SelectCurrencyViewController
         
         selectCurrencyViewController.isSourceCurrency = true
         selectCurrencyViewController.selectedCurrency = sourceCurrencyButton.currentTitle!

      }
      
   }
   
   // VIEW DID LOAD //
   override func viewDidLoad() {
      super.viewDidLoad()
      
      loadSelectedCurrencySettings()
      
      if (UserDefaults.standard.object(forKey: "isFirstTimeLoadingCurrencies") as? Bool) == nil {
         
         currencyConversionView.isHidden = true
         getCurrencyList()
         
         
      } else {
         
         loader.stopAnimating()
         loadConversions()
         
      }
      
      NotificationCenter.default.addObserver(self, selector: #selector(CurrencyConverterViewController.resetConversionPage),name:NSNotification.Name(rawValue: "popupClosed"), object: nil)
      
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   
   
   /***************************************************************/
   //               !!!TABLE FUNCTIONS!!!
   /***************************************************************/
   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      return conversions.count
      
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyTableViewCell", for: indexPath) as! CurrencyTableViewCell
      
      var array = Array(conversions.keys).sorted(by: sortFunc)
      
      let sourceAmount = String(format: "%.2f", (conversions[array[indexPath.row]]?.sourceAmount)!)
      let targetAmount = String(format: "%.2f", (conversions[array[indexPath.row]]?.targetAmount)!)
      
      cell.sourceCurrencyAmountLabel.text = sourceAmount
      cell.sourceCurrencyLabel.text = conversions[array[indexPath.row]]?.sourceCurrency
      cell.targetCurrencyAmountLabel.text = targetAmount
      cell.targetCurrencyLabel.text = conversions[array[indexPath.row]]?.targetCurrency
      
      return cell
      
   }
   
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == UITableViewCellEditingStyle.delete {
         
         let timestamp = Array(conversions.keys).sorted(by: sortFunc)[indexPath.row]
         
         deleteData(timestamp: timestamp)
         conversions[timestamp] = nil
         
         conversionsTable.reloadData()
         
         if conversions.count == 0 {
            
            clickSaveConversionPrompt.isHidden = false
            
         }
         
      }
      
   }
   
   // SORTFUNC - Sort greatest to least //
   func sortFunc(num1: Int, num2: Int) -> Bool {
      
      return num1 > num2
      
   }
   
   // LOAD THE CURRENCY PICKER SETTINGS //
   func loadSelectedCurrencySettings() {
      
      if let sourceCurrency = UserDefaults.standard.object(forKey: "sourceCurrency") as? String {
         
         sourceCurrencyButton.setTitle(sourceCurrency, for: .normal)
         
      } else { // If first time using, set source default to USD
         
         sourceCurrencyButton.setTitle("USD", for: .normal)
         UserDefaults.standard.set("USD", forKey: "sourceCurrency")
         
      }
      
      if let targetCurrency = UserDefaults.standard.object(forKey: "targetCurrency") as? String {
         
         targetCurrencyButton.setTitle(targetCurrency, for: .normal)
         
      } else { // If first time using, set target default to JPY
         
         targetCurrencyButton.setTitle("JPY", for: .normal)
         UserDefaults.standard.set("JPY", forKey: "targetCurrency")
         
      }
      
   }
   
   // SAVE TABLE SETTINGS TO PERMANANT MEMORY //
   func saveSelectedCurrencySettings(newSourceCurrency: String, newTargetCurrency: String) {
      
      UserDefaults.standard.set(newSourceCurrency, forKey: "sourceCurrency")
      
      UserDefaults.standard.set(newTargetCurrency, forKey: "targetCurrency")
      
   }
   
   
   // GET LIST OF CURRENCIES FROM API - ONLY USED FIRST TIME APP RUNS //
   func getCurrencyList() {
      
      let url = URL(string: "http://www.apilayer.net/api/list?access_key=" + key)
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            print(error)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  var numberOfCurrencies = 0
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  let currenciesArray = jsonResult["currencies"] as! [String: String]
                  
                  for (abbreviation, currency) in currenciesArray {
                     
                     self.currencies[abbreviation] = currency
                     numberOfCurrencies += 1
                     
                  }
                  
                  
                  DispatchQueue.main.sync(execute: {
                     
                     print("\(numberOfCurrencies) currencies saved")
                     if self.saveToCoreData() {
                        self.isFirstTime = false
                        UserDefaults.standard.set(self.isFirstTime, forKey: "isFirstTimeLoadingCurrencies")
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
   
   // SAVE LIST OF CURRENCIES TO CORE DATA //
   func saveToCoreData() -> Bool {
      
      var isSuccess = false
      
      var numberOfCurrencies = 0
      
      for (abbreviation, currency) in currencies {
         
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let context = appDelegate.persistentContainer.viewContext
         let data = NSEntityDescription.insertNewObject(forEntityName: "Currency_List", into: context)
         
         data.setValue(abbreviation, forKey: "abbreviation")
         data.setValue(currency, forKey: "currency")
         
         if abbreviation == "USD" || abbreviation == "JPY" {
            
            data.setValue(true, forKey: "recently_used")
            data.setValue(Int(NSDate().timeIntervalSince1970), forKey: "timestamp_used")
            
         } else {
         
         data.setValue(false, forKey: "recently_used")
         data.setValue(0, forKey: "timestamp_used")
         
         }
         
         do {
            try context.save()
            isSuccess = true
            numberOfCurrencies += 1
            
         } catch {
            
            print("There was an error " + currency)
            
         }
      }
      
      print("\(numberOfCurrencies) currencies saved")
      currencyConversionView.isHidden = false
      loader.stopAnimating()
      
      return isSuccess
      
   }
   
   
   // LOAD CONVERSION FROM CORE DATA TO BE SHOWN IN TABLE //
   func loadConversions() {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Currency_Conversions")
      
      request.returnsObjectsAsFaults = false
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            clickSaveConversionPrompt.isHidden = true
            
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
            
            conversionsTable.reloadData()
         }
         
         
      } catch {
         
         print("Error loading past conversions")
         
      }
      
      
   }
   
   // GET EXCHANGE RATE FOR SOURCE AND TARGET CURRENCIES//
   func getExchangeRate() {
      
      targetAmountLoader.startAnimating()
      
      let sourceCurrency = sourceCurrencyButton.currentTitle!
      let targetCurrency = targetCurrencyButton.currentTitle!
      
      print(sourceCurrency)
      print(targetCurrency)
      
      var sourceRate = 0.0
      var targetRate = 0.0
      
      let url = URL(string: "http://www.apilayer.net/api/live?access_key=" + key + "&currencies=" + sourceCurrency + "," + targetCurrency)
      
      let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
         
         if error != nil {
            
            print(error)
            
         } else {
            
            if let urlContent = data {
               
               do {
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  let currenciesArray = jsonResult["quotes"] as! [String: Double]
                  
                  print(currenciesArray)
                  
                  for (currency, rate) in currenciesArray {
                     
                     if currency == "USD" + sourceCurrency {
                        
                        sourceRate = rate
                        
                     } else if currency == "USD" + targetCurrency {
                        
                        targetRate = rate
                        
                     } else {
                        
                        print("ERROR OCCURED!")
                        
                     }
                     
                  }
                  
                  DispatchQueue.main.sync(execute: {
                     
                     self.convert(sourceRate: sourceRate, targetRate: targetRate)
                     
                  })
                  
                  
               } catch {
                  
                  print("Error processing data")
                  
               }
               
            }
            
         }
         
      }
      task.resume()
      
   }
   
   // CONVERT //
   func convert(sourceRate: Double, targetRate: Double) {
      
      if Double(sourceAmount.text!) != nil {
         
         let sourceValueInDollars = (1/sourceRate) * Double(sourceAmount.text!)!
         
         let targetAmountDouble = sourceValueInDollars * targetRate
         
         targetAmountLoader.stopAnimating()
         targetAmount.text = String(format: "%.2f", targetAmountDouble)
      }
      
   }
   
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
         loadConversions()
         isSuccess = true
         
      } catch {
         
         print("ERROR SAVING DATA")
         
      }
      
      return isSuccess
      
   }
   
   // DELETE DATA AT A CERTAIN TIMESTAMP //
   func deleteData(timestamp: Int) {
      
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
   
   // DELETE ALL DATA, NOT CURRENTLY IMPLEMENTED //
   func deleteAllData(entity: String)
   {
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let managedContext = appDelegate.persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
      fetchRequest.returnsObjectsAsFaults = false
      
      var i = 1
      
      do
      {
         let results = try managedContext.fetch(fetchRequest)
         if results.count > 0 {
            for managedObject in results
            {
               let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
               managedContext.delete(managedObjectData)
               print("Deleted \(i)")
               i += 1
            }
         }
         
         do {
            try managedContext.save()
            
            print("SAVED")
         } catch {
            
            
         }
      } catch let error as NSError {
         print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
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
