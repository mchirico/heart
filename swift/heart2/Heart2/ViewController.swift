//
//  ViewController.swift
//  heart2
//
//  Created by Michael Chirico on 12/9/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    //testWorkouts()
    
    let h = HealthKitManager()
    h.requestAccessToHealthKit()
  }

  
  func getDate(dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ssa"
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter.date(from: dateString)!
  }
  
  func testWorkouts() {
    
    
    var count = 0
    
    let startString = "2017-10-10 9:56:25pm"
    let endString =  "2018-12-08 9:56:25pm"
    let startDate = getDate(dateString: startString)
    let endDate = getDate(dateString: endString)
    
    let h = HealthKitManager()
    h.requestAccessToHealthKit()
    
    h.getRunWorkouts(startDate: startDate,
                     endDate: endDate) {
                      result in
                      // Here is where we would do work...
                      
                      let uuid = UUID(uuidString: "799F54F2-BFF9-424F-B701-45B3AF957077")
                      
                      count = result.records.count
                      
                      let sd = result.records[uuid!]?.startDate
                      let ed = result.records[uuid!]?.endDate
                      
                      h.getWatchDistance(withStart: sd!, endDate: ed!) {
                        result in

                        return("stuff")
                      }
                      

                      return("Some future value")
                      
    }
    

    
  }


}

