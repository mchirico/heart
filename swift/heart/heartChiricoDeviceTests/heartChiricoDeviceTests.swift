//
//  heartChiricoDeviceTests.swift
//  heartChiricoDeviceTests
//
//  Created by Michael Chirico on 12/7/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

import XCTest
import UIKit
import Firebase
import GoogleSignIn
@testable import heart

class heartChiricoDeviceTests: XCTestCase {

    override func setUp() {

    }

    override func tearDown() {

    }

  func getDate(dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ssa"
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter.date(from: dateString)!
  }
  
  
  
    func testWorkouts() {

       let expectation = self.expectation(
        description: "Records")
      
      let expectation2 = self.expectation(
        description: "Distance")
      
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
                          expectation2.fulfill()
                          return("stuff")
                        }
                        
                       expectation.fulfill()
                        return("Some future value")
       
      }
      
       waitForExpectations(timeout: 5, handler: nil)
      

       XCTAssert(count == 222)
      
    }

    func testPerformanceExample() {

        self.measure {

        }
    }

}
