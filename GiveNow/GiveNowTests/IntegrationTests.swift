//
//  IntegrationTests.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/21/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import XCTest
import CoreLocation

@testable import GiveNow

class IntegrationTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
//        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParseQuery() {
        let expectation = self.expectationWithDescription("Parse Query")

        let backend = Backend.sharedInstance()
        
        let coordinate = CLLocationCoordinate2DMake(52.50722, 13.49963)
        backend.fetchDonationCentersNearCoordinate(coordinate) { (results, error) -> Void in
            XCTAssertNil(error)
            XCTAssertNotNil(results)
            XCTAssert(results?.count > 0)
            
            
            
            let first = results?.first
            XCTAssertNotNil(first)
            
            if let dropOffAgency = first as? DropOffAgency {
                XCTAssertNotNil(dropOffAgency.objectId)
            }
            else {
                XCTAssert(false, "First should be cast to DropOffAgency")
            }
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10, handler: { (error) -> Void in
            // done
        })
    }
    
}
