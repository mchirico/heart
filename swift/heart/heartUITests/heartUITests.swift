//
//  heartUITests.swift
//  heartUITests
//
//  Created by Michael Chirico on 6/24/18.
//  Copyright © 2018 Michael Chirico. All rights reserved.
//


import XCTest
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import GoogleSignIn

class heartUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        

        continueAfterFailure = false
        XCUIApplication().launch()


    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}

