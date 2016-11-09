//
//  APIKeys.swift
//  The World App
//
//  Created by Kyle Stewart on 11/6/16.
//  Copyright © 2016 Kyle Stewart. All rights reserved.
//

class APIKeys {

   private let currencyAPIKey = "a813f08491bba38f9ed22bf31c3ecd54"
   private let weatherAPIKey = "58cfe76c601f5cfff47b22bc9cad0e1b"
   private let googleTranslatorAPIKey = "AIzaSyARJ9VY_g7QjwsMplOFZbq9i5Jzrraz7A0"
   private let clockAPIKey = "Y4GZZZOFMR8R"
   
   func getCurrencyAPIKey() -> String           { return currencyAPIKey }
   func getWeatherAPIKey() -> String            { return weatherAPIKey }
   func getGoogleTranslatorAPIKey() -> String   { return googleTranslatorAPIKey }
   func getClockAPIKey() -> String              { return clockAPIKey }
   
}
