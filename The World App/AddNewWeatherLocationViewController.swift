//
//  AddNewWeatherLocationViewController.swift
//  World Traveler's App
//
//  Created by Kyle Stewart on 9/14/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit
import CoreData

class AddNewWeatherLocationViewController: UIViewController {
   
   // VARIABLES //
   
   var validLocation = false
   
   @IBOutlet var locationInput: UITextField!
   @IBOutlet var loader: UIActivityIndicatorView!
   
   @IBAction func cancelButton(_ sender: AnyObject) {
      
      closePopup()
      
   }

   
   @IBAction func addButton(_ sender: AnyObject) {
      
      search()
      
   }
   
   func search() {
      
      if locationInput.text != "" {
         
         loader.startAnimating()
         
         WeatherDataApi().getWeatherData(location: locationInput.text!, completeHandler: { (success, errorType, message) in
            
            if success {
               
               self.loader.stopAnimating()
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddWeatherLocationPopupClosed"), object: nil)
               self.closePopup()
               
            } else {
               
               self.loader.stopAnimating()
               AlertsViewController().errorMessage(currentViewController: self, errorType: errorType, message: message)
               self.locationInput.text = ""
               
            }
            
         })
         
      } else {
         
         AlertsViewController().errorMessage(currentViewController: self, errorType: "generic", message: "Please enter a city")
         
      }
      
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.0)
      
   }
   
   override func viewDidDisappear(_ animated: Bool) {
      closePopup()
   }
   
   func closePopup() {
      
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddWeatherLocationPopupClosed"), object: nil)
      self.dismiss(animated: true, completion: nil)
      
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      
   }
   
   
   // Manage Keyboard, let the user exit
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      self.view.endEditing(true)
   }
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      
      search()
      
      return true
   }
   
   
   
}
