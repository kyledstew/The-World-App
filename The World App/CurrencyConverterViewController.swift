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
   
   var sourceCurrencySelected = true
   
   var conversions = ConversionsData().loadConversions()
   
   var refresher: UIRefreshControl!
   
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
   @IBOutlet var updatedTime: UILabel!
   
   // UI VIEWS //
   @IBOutlet var currencyConversionView: UIView!
   @IBOutlet var loaderView: UIView!
   
   @IBAction func sourceCurrencyButtonPressed(_ sender: AnyObject) {
      
      sourceCurrencySelected = true
      BlurVisualEffectViewController().enableBlur(temp: self)
      
   }
   
   @IBAction func targetCurrencyButtonPressed(_ sender: AnyObject) {
      
      sourceCurrencySelected = false
      BlurVisualEffectViewController().enableBlur(temp: self)
      
   }
   
   @IBAction func switchButtonPressed(_ sender: AnyObject) {
      
      let newTargetCurrency = sourceCurrencyButton.titleLabel?.text
      let newSourceCurrency = targetCurrencyButton.titleLabel?.text
      
      sourceCurrencyButton.setTitle(newSourceCurrency, for: .normal)
      targetCurrencyButton.setTitle(newTargetCurrency, for: .normal)
      
      SelectedCurrencySettings().saveSelectedCurrencySettings(newSourceCurrency:  newSourceCurrency!, newTargetCurrency: newTargetCurrency!)
   
      callConvert()
      
   }
   
   @IBAction func sourceAmountValueChanged(_ sender: AnyObject) {

      callConvert()
      
   }
   
   @IBAction func saveConversion(_ sender: AnyObject) {
      
      if sourceAmount.text != "" && Double(sourceAmount.text!) != nil {
         
         clickSaveConversionPrompt.isHidden = true
         updatedTime.isHidden = false
         
         if ConversionsData().saveConversion(sourceAmount: Double(sourceAmount.text!)!, sourceCurrency: sourceCurrencyButton.currentTitle!, targetAmount: Double(targetAmount.text!)!, targetCurrency: targetCurrencyButton.currentTitle!) {
         
            swipeToRefresh()
            
            print("Saved Successfully")
            
         }
      }
      
   }
   
   func swipeToRefresh() {
      
      refresher = UIRefreshControl()
      conversions = ConversionsData().loadConversions()
      
      if conversions.count > 0 && !refresher.isRefreshing {
         
         refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
         
         refresher.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
         
         conversionsTable.addSubview(refresher)
         
         refreshData()
         
      }
      
      
   }
   
   func refreshData() {
      
      ConversionsData().refreshConversions { (success, errorType, message) in

         if success {
            
            self.conversions = ConversionsData().loadConversions()
            self.updatedTime.text = "Updated " + TimeString().getTimeString().updatedTime
            self.conversionsTable.reloadData()
            
         } else {
            
            AlertsViewController().errorMessage(currentViewController: self, errorType: errorType, message: message)
            
         }

         self.refresher.endRefreshing()
         
      }
      
      
   }
   
   func callConvert() {
      
      if sourceAmount.text != "" && Double(sourceAmount.text!) != nil {
         
         targetAmount.text = ""
         targetAmountLoader.startAnimating()
         
         var conversionInfo = ConversionInfo(sourceAmount: Double(sourceAmount.text!)!, sourceCurrency: sourceCurrencyButton.currentTitle!, targetAmount: nil, targetCurrency: targetCurrencyButton.currentTitle!)
         
         Convert().getExchangeRate(conversionInfo: conversionInfo, completionHandler: { (targetAmount, success, errorType, message) in
            
            if success{
               
               self.targetAmountLoader.stopAnimating()
               
               conversionInfo.targetAmount = targetAmount
               
               self.targetAmount.text = String(format: "%.2f", conversionInfo.targetAmount!)
               
            } else {
               
               AlertsViewController().errorMessage(currentViewController: self, errorType: errorType, message: message)
               
            }
            
         })
         

         
      } else {
         
         print("Not double....")
         targetAmount.text = ""
         
      }
      
   }
   
   func resetConversionPage() {
      
      BlurVisualEffectViewController().disableBlur(temp: self)
      sourceCurrencyButton.setTitle(SelectedCurrencySettings().getSourceCurrency(), for: .normal)
      targetCurrencyButton.setTitle(SelectedCurrencySettings().getTargetCurrency(), for: .normal)
      
      callConvert()
      
   }
   
   
   // VIEW DID LOAD //
   override func viewDidLoad() {
      super.viewDidLoad()
      
      sourceCurrencyButton.setTitle(SelectedCurrencySettings().getSourceCurrency(), for: .normal)
      targetCurrencyButton.setTitle(SelectedCurrencySettings().getTargetCurrency(), for: .normal)
      
      if (UserDefaults.standard.object(forKey: "isFirstTimeLoadingCurrencies") as? Bool) == nil {
         
         loader.startAnimating()
         currencyConversionView.isHidden = true
         
         CurrencyDataAPI().getCurrencyList(completionHandler: {( success, errorType, message ) -> Void in
         
            if success {
            
               self.currencyConversionView.isHidden = false
               self.loader.stopAnimating()
            
            } else {
               
               self.loader.stopAnimating()
               AlertsViewController().errorMessage(currentViewController: self, errorType: errorType, message: message)
               
            }
         
         })
         
      } else {
         
         swipeToRefresh()
         
      }
      
      NotificationCenter.default.addObserver(self, selector: #selector(CurrencyConverterViewController.resetConversionPage),name:NSNotification.Name(rawValue: "SelectCurrencyPopupClosed"), object: nil)
      
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
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
   
   /***************************************************************/
   //               !!!TABLE FUNCTIONS!!!
   /***************************************************************/
   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      if conversions.count > 0 {
         clickSaveConversionPrompt.isHidden = true
         updatedTime.isHidden = false
      }
      
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
         
         ConversionsData().deleteConversion(timestamp: timestamp)
         conversions[timestamp] = nil
         
         conversionsTable.reloadData()
         
         if conversions.count == 0 {
            
            clickSaveConversionPrompt.isHidden = false
            updatedTime.isHidden = true
            
         }
         
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
