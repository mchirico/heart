//
//  heartTests.swift
//  heartTests
//
//  Created by Michael Chirico on 6/24/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//

import XCTest
import UIKit
import Firebase
import GoogleSignIn
@testable import heart


class heartTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testSQL() {
    let s = SQLiteTest()
    XCTAssert(s.checkFile(file:"hr.sqlite"))
    print("\n\n ************** \n\n")
    print(s.tableNames)
    print("\n\n ************** \n\n")
    
    
  }
  
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  
  func testGetURL() {
    
    let r = Request()
    r.getURL(url: "https://storage.googleapis.com/montco-stats/helloText.txt")
    XCTAssert(r.contents == "Hello World!\n","Should be Hello World!\n")
    
    
  }
  
  
  func testWithInnerClass(){
    // let h = HealthKitManager()
    // h.requestAuthorization(completion: <#T##(Bool, Error?) -> Void#>)
    
  }
  
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
