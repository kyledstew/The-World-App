//
//  DeleteCoreData.swift
//  The World App
//
//  Created by Kyle Stewart on 11/6/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import CoreData
import UIKit

class DeleteCoreData {

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

}
