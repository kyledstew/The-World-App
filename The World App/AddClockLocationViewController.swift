//
//  AddClockLocationViewController.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 9/16/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class AddClockLocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
   
   var timeZones = [String: String] ()
   var sectionName = "Country"
   var selectedCountry = ""
   
   @IBOutlet var timeZonesTable: UITableView!
   @IBOutlet var searchBar: UISearchBar!
   @IBAction func cancelButton(_ sender: Any) {
      
      if sectionName == "Country" {
      
         closePopup()
      
      } else {
         
         sectionName = "Country"
         selectedCountry = ""
         timeZones = TimeZoneData().loadTimeZones()
         
      }
      
      timeZonesTable.reloadData()
      
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      timeZones = TimeZoneData().loadTimeZones()
      
      view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.0)
      
   }
   
   override func viewDidDisappear(_ animated: Bool) {
      closePopup()
   }
   
   func closePopup() {
      
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddTimeZonePopupClosed"), object: nil)
      self.dismiss(animated: true, completion: nil)
      
   }
   
   public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) // called when text changes (including clear)
   {
      if sectionName == "Country" {
         
         timeZones = TimeZoneData().loadTimeZones(countrySearchText: searchText)
      
      } else {
         
         timeZones = TimeZoneData().loadTimeZones(countrySearchText: selectedCountry, locationSearchText: searchText)
         
      }
      
      timeZonesTable.reloadData()
      
   }
   
   /***************************************************************/
   //               !!!TABLE FUNCTIONS!!!
   /***************************************************************/
   

   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      if sectionName == "Country" {
         
         return removeDuplicates(array: Array(timeZones.values)).count
         
      } else {
         
         return Array(timeZones.keys).count
         
      }
      
   }
   
   public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?  {
      
      return sectionName
      
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      var tempArray = [String] ()
      
      if sectionName == "Country" {
      
         tempArray = removeDuplicates(array: Array(timeZones.values).sorted())
      
      } else {
         
         tempArray = Array(timeZones.keys).sorted()
         
      }
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "TimeZoneTableViewCell", for: indexPath)
      
      cell.textLabel?.text = tempArray[indexPath.row]
      
      return cell
      
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
      var tempArray = [String] ()
      
      if sectionName == "Country" {
         
         tempArray = removeDuplicates(array: Array(timeZones.values).sorted())
         selectedCountry = tempArray[indexPath.row]
         
         timeZones = TimeZoneData().loadTimeZones(countrySearchText: selectedCountry)
         sectionName = selectedCountry
         searchBar.text = ""
         timeZonesTable.reloadData()
         
      } else {
         
         tempArray = Array(timeZones.keys).sorted()
         print(tempArray[indexPath.row])
         setActiveTrue(locationName: tempArray[indexPath.row])
         closePopup()
         
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
   
   // SAVE ACTIVE VAR TO TRUE IN CORE DATA //
   func setActiveTrue(locationName: String) {
      
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      let context = appDelegate.persistentContainer.viewContext
      let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TimeZones")
      
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
                  
                  NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadClocksTable"), object: nil)
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
   
   /*
    
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
    
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadClocksTable"), object: nil)
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
    */
   
}
