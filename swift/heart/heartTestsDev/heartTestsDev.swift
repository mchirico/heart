//
//  heartTestsDev.swift
//  heartTestsDev
//
//  Created by Michael Chirico on 12/2/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//


import XCTest
import UIKit
import Firebase
import GoogleSignIn
@testable import heart


class heartTestsDev: XCTestCase {

    override func setUp() {

    }

    override func tearDown() {

    }
  
  func testReadExerciseTime() {
    let hkm = HealthKitManager()

    let startDate = Date().addingTimeInterval(-1*8*60*60)
    let endDate = Date()
    hkm.walkingRunningWatchDistance(withStart: startDate, end: endDate)
    
  }

    func testExample() {

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
