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
    
    func logOut(completionHandler: BackendFunctionCompletionHandler?) {
        guard let completionHandler = completionHandler else {
            return
        }
    
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            if let error = error {
                completionHandler(false, error)
            }
            else {
                completionHandler(true, nil)
            }
        }
    }
    
    func sendCodeToPhoneNumber(phoneNumber : String, completionHandler: BackendFunctionCompletionHandler?) {
        guard let completionHandler = completionHandler else {
            return
        }
        
        
        let smsBody = NSLocalizedString("SMS Body", comment: "SMS Body")
        let params = ["phoneNumber" : completePhoneNumber(phoneNumber), "body" : smsBody]
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
        
        let params = ["phoneNumber" : completePhoneNumber(phoneNumber), "codeEntry" : codeEntry]
        print(params)
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
            // Are categories related to donation centers?
            let query = PFQuery(className: "DonationCategory")
            query.orderByAscending("priority")
            //query.limit = 9
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
    
    func saveDonation(donor: User, categories: [DonationCategory], completionHandler: ((Donation?, NSError?) -> Void)?) {
        guard let completionHandler = completionHandler else {
            return
        }

        let donation = Donation()
        donation.donor = donor
        donation.donationCategories = categories
        
        donation.saveInBackgroundWithBlock({ (success, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                completionHandler(donation, nil)
            }
        })
    }
    
    func fetchDonationsForDonor(donor : User, completionHandler: (([Donation]?, NSError?) -> Void)?) {
        guard let completionHandler = completionHandler else {
            return
        }

        guard let query = Donation.query() else {
            return
        }
        
        query.whereKey(Donation.Keys.donor.rawValue, equalTo: donor)
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                if let donations = results as? [Donation] {
                    completionHandler(donations, nil)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey : "Unexpected class"]
                    let error = NSError(domain: "Backend", code: 1, userInfo: userInfo)
                    completionHandler(nil, error)
                }
            }
        }
    }
    
    func saveVolunteer(user : User, completionHandler: ((Volunteer?, NSError?) -> Void)?) {
        guard let completionHandler = completionHandler else {
            return
        }
        
        // check if the volunteer already exists for this user
        fetchVolunteerForUser(user) { (volunteer, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                if let volunteer = volunteer {
                    completionHandler(volunteer, nil)
                }
                else {
                    // save a new volunteer if there was not an existing volunteer for this user
                    let volunteer = Volunteer()
                    volunteer.user = user
                    volunteer.isApproved = false
                    
                    volunteer.saveInBackgroundWithBlock { (success, error) -> Void in
                        if let error = error {
                            completionHandler(nil, error)
                        }
                        else {
                            completionHandler(volunteer, nil)
                        }
                    }
                }
            }
        }
     }
    
    func fetchVolunteerForUser(user : User, completionHandler:((Volunteer?, NSError?) -> Void)?) {
        guard let completionHandler = completionHandler else {
            return
        }
        
        if let query = Volunteer.query() {
            query.whereKey(Volunteer.Keys.user.rawValue, equalTo: user)
            query.getFirstObjectInBackgroundWithBlock({ (result, error) -> Void in
                if let error = error {
                    completionHandler(nil, error)
                }
                else {
                    if let volunteer = result as? Volunteer {
                        completionHandler(volunteer, nil)
                    }
                    else {
                        completionHandler(nil, nil)
                    }
                }
            })
        }
    }
    
    private func completePhoneNumber(phoneNumber : String) -> String {
        // Note: automatically add the country code of 1 for US
        return phoneNumber.characters.count == 11 ? phoneNumber : "1\(phoneNumber)"
    }

}

extension Parse {
    
    // Call this function before setApplicationId:clientKey: in your AppDelegate
    class func registerSubclasses() {
        
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            User.registerSubclass()
            DropOffAgency.registerSubclass()
            PickupRequest.registerSubclass()
            Donation.registerSubclass()
            DonationCategory.registerSubclass()
            Volunteer.registerSubclass()
        }
        
    }
}
