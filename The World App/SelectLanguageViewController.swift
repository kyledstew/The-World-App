//
//  SelectLanguageViewController.swift
//  The World App
//
//  Created by Kyle Stewart on 11/8/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

import UIKit

class SelectLanguageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
   
   var sections: [LanguageSection] = []
   
   var isSourceLanguage = true
   var selectedLanguage = ""
   
   // UI ITEMS //
   @IBOutlet var languageTable: UITableView!
   
   @IBAction func cancelButton(_ sender: Any) {
      
      closePopup()
      
   }
   override func viewDidLoad() {
      super.viewDidLoad()
      
      sections = LanguageSectionsData().loadLanguageList()
      
      view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.0)
      
   }
   
   override func viewDidDisappear(_ animated: Bool) {
      closePopup()
   }
   
   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }
   
   func closePopup() {
      
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SelectLanguagePopupClosed"), object: nil)
      self.dismiss(animated: true, completion: nil)
      
   }
   
   public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) // called when text changes (including clear)
   {
      
      print(searchText)
      
      sections = LanguageSectionsData().loadLanguageList(searchText: searchText)
      
      languageTable.reloadData()
      
   }
   
   /***************************************************************/
   //               !!!TABLE FUNCTIONS!!!
   /***************************************************************/
   
   public func numberOfSections(in tableView: UITableView) -> Int {
      
      return sections.count
      
   }
   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
      return sections[section].items.count
      
   }
   
   public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?  {
      
      return sections[section].heading
      
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      
      let tempArray = Array(sections[indexPath.section].items.keys).sorted()
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageTableViewCell", for: indexPath) as! LanguageSelectorTableViewCell
      
      if tempArray[indexPath.row] == selectedLanguage {
         
         cell.checkMark.isHidden = false
         
      } else {
         
         cell.checkMark.isHidden = true
         
      }
      
      cell.languageLabel.text = tempArray[indexPath.row]
      
      return cell
      
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let tempArray = Array(sections[indexPath.section].items.keys).sorted()
      
      selectedLanguage = tempArray[indexPath.row]
      
      if isSourceLanguage {
         
         SelectedLanguageSettings().saveSelectedLanguageSettings(newSourceLanguage: selectedLanguage)
         
      } else {
         
         SelectedLanguageSettings().saveSelectedLanguageSettings(newTargetLanguage: selectedLanguage)
         
      }
      
      LanguageSectionsData().setRecentlyUsed(language: selectedLanguage)
      
      closePopup()
      
   }
   
}
