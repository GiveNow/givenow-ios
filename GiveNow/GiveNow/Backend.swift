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
import libPhoneNumber_iOS

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
    
    func savePickupRequest(donationCategories: [DonationCategory], address: String, location: PFGeoPoint, note: String, completionHandler: ((PickupRequest?, NSError?) -> Void)?) {
        guard let completionHandler = completionHandler else {
            return
        }
        
        let pickupRequest = PickupRequest()
        pickupRequest.donationCategories = donationCategories
        pickupRequest.address = address
        pickupRequest.location = location
        pickupRequest.note = note
        
        pickupRequest.saveInBackgroundWithBlock({ (success, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                completionHandler(pickupRequest, nil)
            }
        })

    }
    
//    func updatePickupRequest(pickupRequest: PickupRequest, pendingVolunteer: User?, confirmedVolunteer: User?, donation: Donation?, donationCategories: [DonationCategory]?, address: String?, location: PFGeoPoint?, note: String?, completionHandler: ((PickupRequest?, NSError?) -> Void)?) {
//        guard let completionHandler = completionHandler else {
//            return
//        }
//        
//        let query = PFObject.query()!
//        query.getObjectInBackgroundWithId(pickupRequest.objectId!) { (object, error) -> Void in
//            if error != nil {
//                completionHandler(nil, error)
//            }
//            else {
//                if pendingVolunteer != nil { pickupRequest.pendingVolunteer = pendingVolunteer }
//                if confirmedVolunteer != nil { pickupRequest.confirmedVolunteer = confirmedVolunteer }
//                if donation != nil { pickupRequest.donation = donation }
//                if donationCategories != nil { pickupRequest.donationCategories = donationCategories }
//                if address != nil { pickupRequest.address = address }
//                if location != nil { pickupRequest.location = location }
//                if note != nil { pickupRequest.note = note }
//                
//                pickupRequest.saveInBackgroundWithBlock({ (success, error) -> Void in
//                    if let error = error {
//                        completionHandler(nil, error)
//                    }
//                    else {
//                        completionHandler(pickupRequest, nil)
//                    }
//                })
//                
//                
//            }
//        }
//    }
    
    func claimOpenPickupRequest(pickupRequest: PickupRequest, completionHandler: ((PickupRequest?, NSError?) -> Void)?) {
        guard let completionHandler = completionHandler else {
            return
        }
        pickupRequest.pendingVolunteer = User.currentUser()
        pickupRequest.saveInBackgroundWithBlock({ (success, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                completionHandler(pickupRequest, nil)
            }
        })
    }
    
    func cancelClaimedPickupRequest(pickupRequest: PickupRequest, completionHandler: ((PickupRequest?, NSError?) -> Void)?) {
        guard let completionHandler = completionHandler else {
            return
        }
        pickupRequest.pendingVolunteer = nil
        pickupRequest.saveInBackgroundWithBlock({ (success, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            }
            else {
                completionHandler(pickupRequest, nil)
            }
        })
    }

    // MARK: Pickup Request Queries for volunteer
    
    func fetchPickupRequestsWithQuery(query: PFQuery, completionHandler: BackendQueryCompletionHandler?) {
        guard let completionHandler = completionHandler else {
            return
        }
        query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            }
            else if results != nil {
                if let pickupRequests = results as? [PickupRequest] {
                    completionHandler(pickupRequests, nil)
                }
                else {
                    print("Could not cast as pickup request")
                    print(results)
                }
            }
            else {
                print("Did not get any results")
            }
        })
    }
    
    // query all pickup requests
    func queryAllPickupRequests() -> PFQuery {
        let query = PFQuery(className: "PickupRequest")
        query.includeKey("donor")
        query.includeKey("donationCategories")
        query.orderByDescending("createdAt")
        return query
    }
    
    // query active pickup requests
    func queryActivePickupRequests() -> PFQuery {
        let query = queryAllPickupRequests()
        query.whereKey("isActive", equalTo: true)
        return query
    }
    
    // query open pickup requests
    func queryOpenPickupRequests() -> PFQuery {
        let query = queryActivePickupRequests()
        query.whereKeyDoesNotExist("pendingVolunteer")
        return query
    }
    
    // query pickup requests I have accepted but not picked up
    func queryMyDashboardPickups() -> PFQuery {
        let query = queryActivePickupRequests()
        query.whereKey("pendingVolunteer", equalTo: User.currentUser()!)
        query.whereKeyDoesNotExist("donation")
        return query
    }
    
    // query pickup requests that I have successfully completed
    func queryMyCompletedPickups() -> PFQuery {
        let query = queryActivePickupRequests()
        query.whereKey("confirmedVolunteer", equalTo: User.currentUser()!)
        query.whereKeyExists("donation")
        return query
    }
    
    // MARK: Pickup request queries for donor
    
    // query pickup requests that I have made
    func queryMyPickupRequests() -> PFQuery {
        let query = queryActivePickupRequests()
        query.whereKey("donor", equalTo: User.currentUser()!)
        return query
    }
    
    // query pickup requests I have made, which currently have a pending volunteer, but no confirmed volunteer
    func queryMyPendingRequests() -> PFQuery {
        let query = queryMyPickupRequests()
        query.whereKeyExists("pendingVolunteer")
        query.whereKeyDoesNotExist("confirmedVolunteer")
        return query
    }
    
    // query my confirmed requests
    func queryMyConfirmedRequests() -> PFQuery {
        let query = queryMyPickupRequests()
        query.whereKeyExists("confirmedVolunteer")
        query.whereKeyDoesNotExist("donation")
        return query
    }
    
    // query my completed requests
    func queryMyCompletedRequests() -> PFQuery {
        let query = queryMyPickupRequests()
        query.whereKeyExists("donation")
        return query
    }
    
    // MARK: Donated pickup requests
    func queryPickupRequestForDonation(donation: Donation) -> PFQuery {
        let query = queryAllPickupRequests()
        query.whereKey("donation", equalTo: donation.objectId!)
        return query
    } 
    
    // MARK: Volunteer
    
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
            query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                if let error = error {
                    completionHandler(nil, error)
                }
                else {
                    if let volunteer = results?.first as? Volunteer {
                        completionHandler(volunteer, nil)
                    }
                    else {
                        completionHandler(nil, nil)
                    }
                }
            })
        }
    }
    
    func phoneCountryCodeForPhoneNumberCurrentLocale() -> Int? {
        let locale = NSLocale.currentLocale()
        return phoneCountryCodeForLocale(locale)
    }
    
    func phoneCountryCodeForLocale(locale : NSLocale) -> Int? {
        if let countryCode = locale.objectForKey(NSLocaleCountryCode) as? String {
            let phoneUtil = NBPhoneNumberUtil()
            let value = Int(phoneUtil.getCountryCodeForRegion(countryCode))
            
            print(value)
            
            return value
        }
        
        return nil
    }
    
    func isValidPhoneNumber(phoneNumber : String) -> Bool {
        var isValid = false
        
        if phoneNumber.hasPrefix("+") {
            let phoneUtil = NBPhoneNumberUtil()
            let parsedNumber = try? phoneUtil.parseWithPhoneCarrierRegion(phoneNumber)
            
            if let parsedNumber = parsedNumber {
                isValid = phoneUtil.isValidNumber(parsedNumber)
            }
        }
        
        return isValid
    }
    
    private func completePhoneNumber(phoneNumber : String) -> String {
        // Note: automatically add the country calling code for the current locale
        if phoneNumber.characters.count >= 10 && phoneNumber.hasPrefix("+") {
            return phoneNumber
        }
        else {
            var phoneCountryCode = phoneCountryCodeForPhoneNumberCurrentLocale()
            if phoneCountryCode == nil {
                phoneCountryCode = 1
            }
            
            if let phoneCountryCode = phoneCountryCode {
                return "+\(phoneCountryCode)\(phoneNumber)"
            }
        }
        
        return phoneNumber
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
