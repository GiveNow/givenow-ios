//
//  Backend.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

// TODO: implement
// See https://github.com/GiveNow/givenow-ios/issues/3

// Integations with Parse and Mapbox geocoding

public typealias BackendFunctionCompletionHandler = (Bool, NSError?) -> Void
public typealias BackendQueryCompletionHandler = ([PFObject]?, NSError?) -> Void

let LoginStatusDidChangeNotification = "LoginStatusDidChangeNotification"

class Backend: NSObject {
    
    static let _sharedInstance = Backend()
    
    static func sharedInstance() -> Backend {
        return Backend._sharedInstance
    }
    
    func sendCodeToPhoneNumber(phoneNumber : String, completionHandler: BackendFunctionCompletionHandler?) {
        guard let completionHandler = completionHandler else {
            return
        }
        
        let smsBody = NSLocalizedString("SMS Body", comment: "SMS Body")
        let params = ["phoneNumber" : phoneNumber, "body" : smsBody]
        print(params)
        PFCloud.callFunctionInBackground("sendCode", withParameters: params) { (result, error) -> Void in
            if let error = error {
                completionHandler(false, error)
            }
            else {
                completionHandler(true, nil)
            }
        }
    }
    
    func logInWithPhoneNumber(phoneNumber : String, codeEntry : String, completionHandler: BackendFunctionCompletionHandler?) {
        guard let completionHandler = completionHandler else {
            return
        }
        
        let params = ["phoneNumber" : phoneNumber, "codeEntry" : codeEntry]
        PFCloud.callFunctionInBackground("logIn", withParameters: params) { (result, error) -> Void in
            if let error = error {
                completionHandler(false, error)
            }
            else {
                if let sessionToken = result as? String {
                    PFUser.becomeInBackground(sessionToken, block: { (user, error) -> Void in
                        if let error = error {
                            completionHandler(false, error)
                        }
                        else {
                            NSNotificationCenter.defaultCenter().postNotificationName(LoginStatusDidChangeNotification, object: nil)
                            completionHandler(true, nil)
                        }
                    })
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : "Unexpected Result"]
                    let error = NSError(domain: "Backend", code: 1, userInfo: userInfo)
                    completionHandler(false, error)
                }
            }
        }
    }
    
    func fetchDonationCentersNearCoordinate(coordinate : CLLocationCoordinate2D, completionHandler: BackendQueryCompletionHandler?) {
        guard let completionHandler = completionHandler else {
            return
        }
        
        let geoPoint = PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let query = PFQuery(className: "DropOffAgency")
        query.whereKey("agencyGeoLocation", nearGeoPoint: geoPoint)
        query.limit = 20
        query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                completionHandler(results, nil)
            }
        })
    }
    
    func fetchDonationsFromUser(user : PFUser, completionHandler: BackendQueryCompletionHandler?) {
        guard let completionHandler = completionHandler else {
            return
        }
        
        let query = PFQuery(className: "Donation")
        query.whereKey("donor", equalTo: user)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                completionHandler(results, nil)
            }
        })
    }
    
    func fetchCategoriesForDonationCenter(donationCenter : PFObject, completionHandler: BackendQueryCompletionHandler?) {
        guard let completionHandler = completionHandler else {
            return
        }
        
        if !"DropOffAgency".isEqualToString(donationCenter.parseClassName) {
            let userInfo = [NSLocalizedDescriptionKey : "Invalid Parse Class: \(donationCenter.parseClassName)"]
            let error = NSError(domain: "Backend", code: 1, userInfo: userInfo)
            completionHandler(nil, error)
        }
        else {
            let query = PFQuery(className: "DonationCategory")
            query.orderByAscending("priority")
            query.limit = 9
            query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                if let error = error {
                    completionHandler(nil, error)
                }
                else {
                    completionHandler(results, nil)
                }
            })
        }
        
        completionHandler(nil, nil)
    }

}
