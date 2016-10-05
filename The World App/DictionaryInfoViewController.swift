//
//  DictionaryInfoViewController.swift
//  The World App
//
//  Created by Kyle Stewart on 10/5/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class DictionaryInfoViewController: UIViewController {

   @IBAction func backButton(_ sender: AnyObject) {
      
      self.dismiss(animated: true, completion: nil)
      
   }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
