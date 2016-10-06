//
//  CurrencyConverterViewController.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 9/20/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class CurrencyConverterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
   
   // VARIABLES //
   var baseCurrency = "USD"
   var firstTime = true
   let key = "a813f08491bba38f9ed22bf31c3ecd54"
   var currencies = [String: String] ()
   struct ConversionInfo {
      
      var sourceAmount: Double?
      var sourceCurrency: String?
      var targetAmount: Double?
      var targetCurrency: String?
      
   }
   var conversions = [Int: ConversionInfo] ()
   var isSourceCurrency = true // keep track of which currency changed
   
   //UI ITEMS //
   @IBOutlet var fromPicker: UIPickerView!
   @IBOutlet var toPicker: UIPickerView!
   @IBOutlet var fromCurrencyButton: UIButton!
   @IBOutlet var loader: UIActivityIndicatorView!
   @IBOutlet var switcher: UIButton!
   @IBOutlet var toCurrencyButton: UIButton!
   @IBOutlet var targetAmountLoader: UIActivityIndicatorView!
   @IBOutlet var fromAmount: UITextField!
   @IBOutlet var toArrow: UIButton!
   @IBOutlet var toAmount: UITextField!
   @IBOutlet var questionButton: UIButton!
   @IBOutlet var clickSaveConversionPrompt: UIView!
   @IBOutlet var clickCurrencyPrompt: UILabel!
   @IBOutlet var conversionsTable: UITableView!
   
   // UI ITEM FUNCS //
   @IBAction func fromCurrencyButton(_ sender: AnyObject) {
      
      fromCurrencyButton.isHidden = true
      fromPicker.isHidden = false
      fromAmount.isHidden = true
      questionButton.isHidden = true
      clickCurrencyPrompt.isHidden = true
      
   }
   
   @IBAction func toCurrencyButton(_ sender: AnyObject) {
      
      isSourceCurrency = false
      toCurrencyButton.isHidden = true
      toPicker.isHidden = false
      toAmount.isHidden = true
      
   }
   
   @IBAction func switchButton(_ sender: AnyObject) {
      
      let fpv = fromPicker.selectedRow(inComponent: 0)
      let tpv = toPicker.selectedRow(inComponent: 0)
      
      fromPicker.selectRow(tpv, inComponent: 0, animated: true)
      toPicker.selectRow(fpv, inComponent: 0, animated: true)
      
      fromCurrencyButton.setTitle(Array(currencies.keys).sorted()[tpv], for: .normal)
      toCurrencyButton.setTitle(Array(currencies.keys).sorted()[fpv], for: .normal)
      
      saveSelectedCurrencySettings(currency: Array(currencies.keys).sorted()[tpv])
      saveSelectedCurrencySettings(currency: Array(currencies.keys).sorted()[fpv], sourceCurrency: false)
      
      if fromAmount.text != "" && Double(fromAmount.text!) != nil {
      
      toAmount.text = ""
      getExchangeRate()
      
      }
   }
   
   @IBAction func questionButton(_ sender: AnyObject) {
      
      if clickCurrencyPrompt.isHidden {
         
         clickCurrencyPrompt.isHidden = false
         
      } else {
         
         clickCurrencyPrompt.isHidden = true
         
      }
      
   }
   
   @IBAction func fromAmountValueChanged(_ sender: AnyObject) {
      
      if fromAmount.text == "" {
         
         toAmount.text = ""
         
      } else if Double(fromAmount.text!) != nil {
         
         getExchangeRate()
         
         
      } else {
         
         print("Not double....")
         toAmount.text = ""
         
      }
      
   }
   
   @IBAction func saveConversion(_ sender: AnyObject) {
      
      if fromAmount.text != "" && Double(fromAmount.text!) != nil {
         
         var curArray = Array(currencies.keys).sorted()
         
         if saveConversion(sourceAmount: Double(fromAmount.text!)!, sourceCurrency: curArray[fromPicker.selectedRow(inComponent: 0)], targetAmount: Double(toAmount.text!)!, targetCurrency: curArray[toPicker.selectedRow(inComponent: 0)]) {
            
            print("Saved Successfully")
            
         }
         
      }
      
   }
   
   // VIEW DID LOAD //
   override func viewDidLoad() {
      super.viewDidLoad()
      
      if (UserDefaults.standard.object(forKey: "firstTimeLoadingCurrencies") as? Bool) == nil {
         
         getCurrencyList()
         
         
      } else {
         
         loadCurrencyList()
         loadConversions()
         
      }
      
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   /***************************************************************/
   //               !!!PICKER FUNCTIONS!!!
   /***************************************************************/
   public func numberOfComponents(in pickerView: UIPickerView) -> Int {
      
      return 1
      
   }
   
   public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      
      return currencies.count
      
   }
   
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      
      var curArray = Array(currencies.keys).sorted()
      
      return curArray[row]
      
   }
   
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      
      var curArray = Array(currencies.keys).sorted()
      
      if isSourceCurrency {
         fromCurrencyButton.setTitle(curArray[row], for: .normal)
         fromPicker.isHidden = true
         fromCurrencyButton.isHidden = false
         fromAmount.isHidden = false
         questionButton.isHidden = false
         
         saveSelectedCurrencySettings(currency: curArray[fromPicker.selectedRow(inComponent: 0)])
         
      } else {
         
         toCurrencyButton.setTitle(curArray[row], for: .normal)
         toPicker.isHidden = true
         toCurrencyButton.isHidden = false
         toAmount.isHidden = false
         
         saveSelectedCurrencySettings(currency: curArray[toPicker.selectedRow(inComponent: 0)], sourceCurrency: false)
         
      }
      
      isSourceCurrency = true
      
      if fromAmount.text == "" {
         
         toAmount.text = ""
         
      } else if Double(fromAmount.text!) != nil {
         
         toAmount.text = ""
         getExchangeRate()
         
         
      } else {
         
         print("Not double....")
         toAmount.text = ""
         
      }
      
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
         
         fromPicker.selectRow(Array(currencies.keys).sorted().index(of: sourceCurrency)!, inComponent: 0, animated: true)
         
         
      } else { // If first time using, set source default to USD
         
         fromPicker.selectRow(Array(currencies.keys).sorted().index(of: "USD")!, inComponent: 0, animated: true)
         
      }
      
      if let targetCurrency = UserDefaults.standard.object(forKey: "targetCurrency") as? String {
         
         toPicker.selectRow(Array(currencies.keys).sorted().index(of: targetCurrency)!, inComponent: 0, animated: true)
         
      } else { // If first time using, set target default to JPY
         
         toPicker.selectRow(Array(currencies.keys).sorted().index(of: "JPY")!, inComponent: 0, animated: true)
         
      }
      
      fromCurrencyButton.setTitle(Array(currencies.keys).sorted()[fromPicker.selectedRow(inComponent: 0)], for: .normal)
      toCurrencyButton.setTitle(Array(currencies.keys).sorted()[toPicker.selectedRow(inComponent: 0)], for: .normal)
      
   }
   
   // SAVE PICKER SETTINGS TO PERMANANT MEMORY //
   func saveSelectedCurrencySettings(currency: String, sourceCurrency: Bool = true) {
      
      if sourceCurrency {
         
         UserDefaults.standard.set(currency, forKey: "sourceCurrency")
         
      } else {
         
         UserDefaults.standard.set(currency, forKey: "targetCurrency")
         
      }
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
                  
                  let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                  
                  let currenciesArray = jsonResult["currencies"] as! [String: String]
                  
                  for (abbreviation, currency) in currenciesArray {
                     
                     self.currencies[abbreviation] = currency
                     
                  }
                  
                  
                  DispatchQueue.main.sync(execute: {
                     
                     self.saveToCoreData()
                     self.firstTime = false
                     UserDefaults.standard.set(self.firstTime, forKey: "firstTimeLoadingCurrencies")
                     
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
         data.setValue(false, forKey: "active")
         
         do {
            try context.save()
            isSuccess = true
            numberOfCurrencies += 1
            
         } catch {
            
            print("There was an error " + currency)
            
         }
      }
      
      print("\(numberOfCurrencies) currencies saved")
      loadCurrencyList()
      
      return isSuccess
      
   }
   
   // LOAD ALL THE CURRENCIES FROM CORE DATA //
   func loadCurrencyList() {
      
      print("Loading data")
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Currency_List")
      
      request.returnsObjectsAsFaults = false
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               
               if let abbreviation = result.value(forKey: "abbreviation") as? String {
                  
                  if let currency = result.value(forKey: "currency") as? String {
                     
                     currencies[abbreviation] = currency
                     
                  }
                  
               }
               
            }
            
            
         }
         
      } catch {
         
         print("Error loading list of currencies")
         
      }
      
      print("Currencies loaded")
      
      fromPicker.reloadAllComponents()
      toPicker.reloadAllComponents()
      loadSelectedCurrencySettings()
      
      toArrow.isHidden = false
      fromCurrencyButton.isHidden = false
      toCurrencyButton.isHidden = false
      questionButton.isHidden = false
      fromAmount.isHidden = false
      toAmount.isHidden = false
      switcher.isHidden = false
      loader.stopAnimating()
      
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
               
               if let timestamp = result.value(forKey: "timestamp") as? Int {
                  
                  if let sourceAmount = result.value(forKey: "source_amount") as? Double {
                     
                     if let sourceCurrency = result.value(forKey: "source_currency") as? String {
                        
                        if let targetAmount = result.value(forKey: "target_amount") as? Double {
                           
                           if let targetCurrency = result.value(forKey: "target_currency") as? String {
                              
                              let temp = ConversionInfo(sourceAmount: sourceAmount, sourceCurrency: sourceCurrency, targetAmount: targetAmount, targetCurrency: targetCurrency)
                              
                              conversions[timestamp] = temp
                              
                           }
                           
                        }
                        
                     }
                     
                  }
                  
               }
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
      
      let sourceCurrency = Array(currencies.keys).sorted()[fromPicker.selectedRow(inComponent: 0)]
      let targetCurrency = Array(currencies.keys).sorted()[toPicker.selectedRow(inComponent: 0)]
      
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
      
      if Double(fromAmount.text!) != nil {
         
         let sourceValueInDollars = (1/sourceRate) * Double(fromAmount.text!)!
         
         let targetAmount = sourceValueInDollars * targetRate
         
         targetAmountLoader.stopAnimating()
         toAmount.text = String(format: "%.2f", targetAmount)
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
