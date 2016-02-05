//
//  InitialViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/13/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Parse

class InitialViewController: BaseViewController, CLLocationManagerDelegate {
    
    var manager:CLLocationManager!
    var pickupRequest:PickupRequest!
    
    var shouldCheckForPendingAlerts = true

    override func viewDidLoad() {
        super.viewDidLoad()
        detectFirstLaunch()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "pushNotificationReceived:", name: "pushNotificationReceived", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showPendingAlertsIfNeeded:", name: "showPendingAlertsIfNeeded", object: nil)
        showPendingAlertsIfPushDisabled()
    }
    
    // MARK: Public functions used to display appropriate workflow
    
    func displayOnboardingViewController() {
        if let vc = fetchViewControllerFromStoryboard("Onboard", storyboardIdentifier: "onboarding") as?OnboardingViewController {
            embedViewController(vc, intoView: view)
        }
    }
    
    func displayMainViewController() {
        manager = CLLocationManager()
        manager.delegate = self
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestWhenInUseAuthorization()
        }
        else if let vc = fetchViewControllerFromStoryboard("Main", storyboardIdentifier: "reveal") as? SWRevealViewController {
            embedViewController(vc, intoView: view)
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print(CLLocationManager.authorizationStatus())
        if CLLocationManager.authorizationStatus() != .NotDetermined {
            if let vc = fetchViewControllerFromStoryboard("Main", storyboardIdentifier: "reveal") as? SWRevealViewController {
                embedViewController(vc, intoView: view)
            }
        }
    }
    
    // MARK: Handling push notifications
    
    func pushNotificationReceived(notification: NSNotification){
        shouldCheckForPendingAlerts = false
        if let dictionary = notification.userInfo {
            let json = JSON(dictionary)
            if let notificationType = json["data"]["type"].string {
                switch notificationType {
                case "claimPickupRequest":
                    handleClaimPickupRequestNotificationReceived(json)
                case "pickupDonation":
                    handleDonationCompleteNotification(json)
                default:
                    handleNotification(json)
                }
            }
        }
        else {
            shouldCheckForPendingAlerts = true
        }
        
    }
    
    func queryMyPickupRequest(completion: (error: NSError?,pickupRequest: PickupRequest?) -> Void) {
        let query = backend.queryMyPickupRequests()
        backend.fetchPickupRequestsWithQuery(query, completionHandler: {(result, error) -> Void in
            if let error = error {
                completion(error: error, pickupRequest: nil)
            }
            else if let result = result {
                if result.count > 0 {
                    if let pickupRequest = result[0] as? PickupRequest {
                        completion(error: nil, pickupRequest: pickupRequest)
                    }
                }
            }
            completion(error: nil, pickupRequest: nil)
        })
    }
    
    // Mark: Claiming pickup request
    
    func handleClaimPickupRequestNotificationReceived(json: JSON) {
        
        //Note: this is dangerous; better to get it from the notification?
        queryMyPickupRequest({(error, result) -> Void in
            if let pickupRequest = result {
                self.pickupRequest = pickupRequest
                let title = NotificationHelper.localizeNotificationTitle(json)
                let message = NotificationHelper.localizeNotificationMessage(json)
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .Default, handler: {(action) in
                    self.donationIsReady()
                }))
                alertController.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .Default, handler: {(action) in
                    self.donationIsNotReady()
                }))
                self.presentViewController(alertController, animated: true, completion: {})
            }
        })
    }
    
    func donationIsNotReady() {
        backend.indicatePickupRequestIsNotReady(pickupRequest, completionHandler: {(result, error) -> Void in
            if let error = error {
                print(error)
            }
            else {
                self.alertActionCompleted()
            }
        })
    }
    
    func donationIsReady() {
        backend.confirmVolunteerForPickupRequest(pickupRequest, completionHandler: {(result, error) -> Void in
            if let error = error {
                print(error)
            }
            else {
                self.alertActionCompleted()
            }
        })
    }
    
    // MARK: Completing donation
    
    func handleDonationCompleteNotification(json: JSON) {
        
        //Note: This is dangerous - better to get it from the notification?
        queryMyPickupRequest({(error, result) -> Void in
            if let pickupRequest = result {
                self.pickupRequest = pickupRequest
                let title = NotificationHelper.localizeNotificationTitle(json)
                let message = NotificationHelper.localizeNotificationMessage(json)
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("done", comment: ""), style: .Default, handler: {(action) in
                    self.donePressed()
                }))
                alertController.addAction(UIAlertAction(title: NSLocalizedString("rate_app", comment: ""), style: .Default, handler: {(action) in
                    self.rateApp()
                }))
                self.presentViewController(alertController, animated: true, completion: {})
            }
        })
    }
    
    
    func rateApp() {
        closeDonation()
        //To Do: Open app store to rate app
    }
    
    func donePressed() {
        closeDonation()
    }
    
    func closeDonation() {
        backend.markComplete(pickupRequest, completionHandler: {(resut, error) -> Void in
            if let error = error {
                print(error)
            }
            else {
                self.alertActionCompleted()
            }
        })
    }
    
    // MARK: Handling other notifications
    
    func handleNotification(json: JSON) {
        let title = NotificationHelper.localizeNotificationTitle(json)
        let message = NotificationHelper.localizeNotificationMessage(json)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("dismiss", comment: ""), style: .Default, handler: {(action) in
            self.alertActionCompleted()
        }))
        self.presentViewController(alertController, animated: true, completion: {})
    }
    
    // MARK: Informing app that alert has been dismissed - views may need to be reloaded
    
    func alertActionCompleted() {
        shouldCheckForPendingAlerts = true
        let localNotification = NSNotification(name: "alertActionCompleted", object: nil, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(localNotification)
    }
    
    // MARK: Dealing with case where push notifications have been disabled or are not determined
    
    
    func showPendingAlertsIfPushDisabled() {
        let permissionStatus = Permissions.systemStatusForNotifications()
        if permissionStatus != .Allowed {
            shouldCheckForPendingAlerts = true
            self.showPendingAlerts()
        }
    }
    
    func showPendingAlertsIfNeeded(notification: NSNotification){
        // Commentary: In general, we should only do this for situations where push is disabled.
        // However, it's possible that push is enabled but the notification was not delivered. In that case, we want
        // the app to act as though push is disabled and display pending results if necessary. BUT we don't want this to collide
        // with the app actually handling push notifications. So we're using this boolean to try and handle that...
        if shouldCheckForPendingAlerts == true {
            showPendingAlerts()
        }
    }
    
    func showPendingAlerts() {
        queryMyPickupRequest({(error, result) -> Void in
            if let pickupRequest = result {
                self.pickupRequest = pickupRequest
                if pickupRequest.pendingVolunteer != nil && pickupRequest.confirmedVolunteer == nil {
                    self.getNameForPendingPickupRequestAlert()
                }
                else if pickupRequest.donation != nil {
                    self.getCategoriesForDonation()
                }
            }
        })
    }
    
    func getNameForPendingPickupRequestAlert() {
        if let user = pickupRequest.pendingVolunteer {
            user.fetchInBackgroundWithBlock({(result, error) -> Void in
                if let volunteer = result as? User {
                    if let name = volunteer.name {
                        self.showPendingPickupRequestAlert(name)
                    }
                    else {
                        let name = String.localizedString("a_volunteer")
                        self.showPendingPickupRequestAlert(name)
                    }
                }
                else {
                    let name = String.localizedString("a_volunteer")
                    self.showPendingPickupRequestAlert(name)
                }
            })
        }
    }
    
    func showPendingPickupRequestAlert(name: String) {
        let title = String.localizedStringWithParameters("push_notif_volunteer_is_ready_to_pickup", phoneNumber: nil, name: name, code: nil)
        let message = NSLocalizedString("dialog_accept_pending_volunteer", comment: "")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("yes", comment: ""), style: .Default, handler: {(action) in
            self.donationIsReady()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("no", comment: ""), style: .Default, handler: {(action) in
            self.donationIsNotReady()
        }))
        self.presentViewController(alertController, animated: true, completion: {})
    }
    
    func getCategoriesForDonation() {
        guard let categories = pickupRequest.donationCategories else {
            return
        }
        var message = NSLocalizedString("donation_complete_message_head", comment: "")
        
        for var i = 0; i < categories.count; i++ {
            categories[i].fetchIfNeededInBackgroundWithBlock({(result, error) -> Void in
                let category = result as! DonationCategory
                let categoryName = category.getName()!
                if i == 0 {
                    message += " \(categoryName)"
                }
                else if i < categories.count - 1 {
                    message += ", \(categoryName)"
                }
                else {
                    message += " \(NSLocalizedString("and", comment: "")) \(categoryName) \(NSLocalizedString("donation_complete_message_tail", comment: ""))"
                    self.showDonationPickedUpAlert(message)
                }
            })
        }
    }
    
    func showDonationPickedUpAlert(message: String) {
        let title = NSLocalizedString("donation_complete_title", comment: "")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("done", comment: ""), style: .Default, handler: {(action) in
            self.donePressed()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("rate_app", comment: ""), style: .Default, handler: {(action) in
            self.rateApp()
        }))
        self.presentViewController(alertController, animated: true, completion: {})
    }
    
    
    
    // MARK: Private
    
    private func detectFirstLaunch(){
        let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
        if !firstLaunch {
            displayOnboardingViewController()
        }
        else {
            displayMainViewController()
        }
    }

}
