//
//  AddClockLocationViewController.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 9/16/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class AddClockLocationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
   
   // VARIABLES //
   var firstTime = true
   var countryNameArray = [String]()
   var locationNameArray = [String]()
   
   // UI ITEMS //
   @IBOutlet var picker: UIPickerView!
   @IBOutlet var loader: UIActivityIndicatorView!
   @IBOutlet var enterCountryPrompt: UILabel!
   @IBOutlet var countryInput: UITextField!
   @IBOutlet var noResultsFoundMessage: UILabel!
   
   // UI ITEM FUNCS //
   @IBAction func questionButton(_ sender: AnyObject) {
      
      if enterCountryPrompt.isHidden == false {
         
         enterCountryPrompt.isHidden = true
         
      } else {
         
         enterCountryPrompt.isHidden = false
         
      }
      
   }
   
   @IBAction func cancelButton(_ sender: AnyObject) {
      
      self.dismiss(animated: true, completion: nil)
      
   }
   
   @IBAction func countryInputTextChange(_ sender: AnyObject) {
      
      if countryInput.text != "" {
         
         noResultsFoundMessage.isHidden = true
         picker.isHidden = true
         loader.startAnimating()
         
         filterResults(searchText: countryInput.text!)
         
         picker.reloadAllComponents()
         picker.isHidden = false
         loader.stopAnimating()
         
      }
      
   }
   @IBAction func addButton(_ sender: AnyObject) {
      
      let selectedLocation = locationNameArray.sorted()[picker.selectedRow(inComponent: 1)]
      
      setActiveTrue(locationName: selectedLocation)
      
   }
   
   
   /***************************************************************/
   //               !!!PICKER FUNCTIONS!!!
   /***************************************************************/
   public func numberOfComponents(in pickerView: UIPickerView) -> Int {
      
      return 2
      
   }
   
   // returns the # of rows in each component..
   public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      
      if (component == 0) {
         
         return countryNameArray.count
         
      } else {
         
         return locationNameArray.count
         
      }
      
   }
   
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      
      if component == 0 {
         
         return countryNameArray.sorted()[row]
         
      } else {
         
         return locationNameArray.sorted()[row]
         
      }
      
   }
   
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      
      
      if component == 0 {
         let selected = countryNameArray.sorted()[picker.selectedRow(inComponent: 0)]
         
         filterResults(searchText: selected, picker: true)
         
         picker.reloadAllComponents()
      }
      
   }
   
   // VIEW DID LOAD //
   override func viewDidLoad() {
      super.viewDidLoad()
      
      let temp = UserDefaults.standard.object(forKey: "firstTime")
      
      if let tempItems = temp as? Bool {
         
         firstTime = tempItems
         
      }
      
      loadData()
      
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      
   }
   
   // SAVE ACTIVE VAR TO TRUE IN CORE DATA //
   func setActiveTrue(locationName: String) {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Clock")
      
      request.returnsObjectsAsFaults = false
      request.predicate = NSPredicate(format: "location_name = %@", locationName)
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               
               result.setValue(true, forKey: "active")
               print(locationName + " set to active")
               
               do {
                  
                  try context.save()
                  
                  print("Saved")
                  
                  self.dismiss(animated: true, completion: nil)
                  
               } catch {
                  
                  print("There was an error saving")
                  
               }
               
            }
            
         }
         
      } catch {
         
         print("No Results")
         
      }
      
   }
   
   // FILTER RESULTS IN ARRAY TO MATCH INPUT TEXT //
   func filterResults(searchText: String, picker: Bool = false ) {
      
      if !picker {
         countryNameArray.removeAll()
      }
      locationNameArray.removeAll()
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Clock")
      
      request.returnsObjectsAsFaults = false
      request.predicate = NSPredicate(format: "country_name contains[c] %@", searchText)
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               if !picker {
                  
                  countryNameArray.append(result.value(forKey: "country_name") as! String)
                  
               }
               
               locationNameArray.append(result.value(forKey: "location_name") as! String)
               
            }
            
         } else {
            
            noResultsFoundMessage.isHidden = false
            
         }
         
         countryNameArray = removeDuplicates(array: countryNameArray)
         
      } catch {
         
         print("No Results")
         
      }
      
   }
   
   // LOAD DATA FROM CORE DATA //
   func loadData() {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Clock")
      
      request.returnsObjectsAsFaults = false
      
      do {
         
         let results = try context.fetch(request)
         
         if results.count > 0 {
            
            for result in results as! [NSManagedObject] {
               
               countryNameArray.append(result.value(forKey: "country_name") as! String)
               locationNameArray.append(result.value(forKey: "location_name") as! String)
               
            }
            
            countryNameArray = removeDuplicates(array: countryNameArray)
            locationNameArray = removeDuplicates(array: locationNameArray)
            
         }
         
         
         picker.isHidden = false
         loader.stopAnimating()
         picker.reloadAllComponents()
         
      } catch {
         
         print("Couldn't get Data")
         
      }
      
   }
   
   // REMOVE DUPLICATES FROM ARRAYS //
   // MULTIPLE LOCATIONS FOR ONE COUNTRY, ONLY HAVE COUNTRY APPEAR ONCE //
   func removeDuplicates(array: [String]) -> [String] {
      
      var arrayNoDuplicates = [String] ()
      
      for value in array {
         
         var valueExists = false
         
         for singleValue in arrayNoDuplicates {
            
            if value == singleValue {
               
               valueExists = true
               
            }
            
         }
         
         if !valueExists {
            
            arrayNoDuplicates.append(value)
            
         }
         
      }
      
      return arrayNoDuplicates
   }
   
   
   // Manage Keyboard, let the user exit
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      self.view.endEditing(true)
   }
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      
      return true
   }
   
   
}
