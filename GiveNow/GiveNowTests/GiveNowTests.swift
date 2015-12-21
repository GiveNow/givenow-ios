//
//  GiveNowTests.swift
//  GiveNowTests
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import XCTest
@testable import GiveNow

class GiveNowTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testValidPhoneNumbers() {
        XCTAssert(Backend.sharedInstance().isValidPhoneNumber("+14158099909"), "Phone number should be valid")
        XCTAssert(Backend.sharedInstance().isValidPhoneNumber("+49 1573 598 4834"), "Phone number should be valid")
        XCTAssert(Backend.sharedInstance().isValidPhoneNumber("+4915735984834"), "Phone number should be valid")
    }
    
    func testInvalidPhoneNumbers() {
        XCTAssert(!Backend.sharedInstance().isValidPhoneNumber("4158099909"), "Phone number should be valid")
        XCTAssert(!Backend.sharedInstance().isValidPhoneNumber("1573 598 4834"), "Phone number should be valid")
        XCTAssert(!Backend.sharedInstance().isValidPhoneNumber("15735984834"), "Phone number should be valid")
        XCTAssert(!Backend.sharedInstance().isValidPhoneNumber("2421"), "Phone number should be valid")
    }
    
    func testPhoneCountryCodes() {
        let usLocale = NSLocale(localeIdentifier: "en_US")
        let deLocale = NSLocale(localeIdentifier: "de_DE")
        
        let usCountryCode = Backend.sharedInstance().phoneCountryCodeForLocale(usLocale)
        let deCountryCode = Backend.sharedInstance().phoneCountryCodeForLocale(deLocale)
        
        XCTAssert(usCountryCode == 1)
        XCTAssert(deCountryCode == 49)
    }
    
    
    

}
