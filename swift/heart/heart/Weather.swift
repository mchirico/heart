//
//  Weather.swift
//  heart
//
//  Created by Michael Chirico on 7/26/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

import Foundation

class Weather {
  
  var ACCESS_TOKEN:String
  let request = Request()
  
  init(_ ACCESS_TOKEN:String) {
    self.ACCESS_TOKEN = ACCESS_TOKEN
  }
  
  func history(start:Date,end:Date,lat:String,lon:String) -> String {
    
    // lat="40.0704370" lon="-75.1276880"
    
    let url = "https://api.weather.gov/points/\(lat),\(lon)"
    //    let url = "https://samples.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(ACCESS_TOKEN)"
    //
    
    
    print("Time: \(start.timeIntervalSince1970)")
    //print(url)
    request.getURL(url: url)
    
    return request.contents
  }
  
}
