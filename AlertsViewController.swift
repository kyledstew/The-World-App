//
//  AlertsViewController.swift
//  The World App
//
//  Created by Kyle Stewart on 11/29/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit


/*
 Error types:
 generic = general error
 connection_error = internet connection
 */

class AlertsViewController: UIViewController {
   
   func errorMessage(currentViewController: UIViewController, errorType: String, message: String) {
      
      
      if errorType == "connection_error" {
         
         noInternet(currentViewController: currentViewController, message: message)
         
      } else {
         
         basicErrorMessage(currentViewController: currentViewController, message: message)
         
      }
      
   }

   private func noInternet(currentViewController: UIViewController, message: String) {
   
      let alertController = UIAlertController(title: "No Internet", message: message, preferredStyle: UIAlertControllerStyle.alert)
         
      alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
         
         guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
         }
         
         if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
               print("Settings opened: \(success)") // Prints true
            })
         }
         
      currentViewController.dismiss(animated: true, completion: nil)
         
      }))
      
      alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
         currentViewController.dismiss(animated: true, completion: nil)
         
      }))
      
      currentViewController.present(alertController, animated: true, completion: nil)
   }
   
   
   private func basicErrorMessage(currentViewController: UIViewController, message: String) {
      
      let alertController = UIAlertController(title: "Oops...", message: message, preferredStyle: UIAlertControllerStyle.alert)
      
      alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
         
      }))
            
      currentViewController.present(alertController, animated: true, completion: nil)
   }

}
