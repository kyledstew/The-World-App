//
//  BlurVisualEffectViewController.swift
//  The World App
//
//  Created by Kyle Stewart on 10/18/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class BlurVisualEffectViewController: UIVisualEffectView {
   
   func enableBlur(temp: UIViewController) {
      
       //self.view.backgroundColor = UIColor.clear
      
      let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
      let blurEffectView = UIVisualEffectView(effect: blurEffect)
      //always fill the view
      blurEffectView.frame = temp.view.bounds
      blurEffectView.tag = 1
      blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      
      temp.view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
   
   }

   func disableBlur(temp: UIViewController) {
      
      if let viewWithTag = temp.view.viewWithTag(1) {
         viewWithTag.removeFromSuperview()
      }
      
   }
   
}
