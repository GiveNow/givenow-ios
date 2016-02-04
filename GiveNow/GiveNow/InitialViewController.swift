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

    override func viewDidLoad() {
        super.viewDidLoad()
        detectFirstLaunch()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "pushNotificationReceived:", name: "pushNotificationReceived", object: nil)
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
        if let dictionary = notification.userInfo {
            print(dictionary)
            
            let json = JSON(dictionary)
            if let notificationType = json["data"]["type"].string {
                switch notificationType {
                case "claimPickupRequest":
                    handleClaimPickupRequestNotificationReceived(json)
                default:
                    handleNotification(json)
                }
            }
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
    
    func handleClaimPickupRequestNotificationReceived(json: JSON) {
        queryMyPickupRequest({(error, result) -> Void in
            if let pickupRequest = result {
                self.pickupRequest = pickupRequest
                let title = NotificationHelper.localizeNotificationTitle(json)
                let message = NotificationHelper.localizeNotificationMessage(json)
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(action) in
                    self.donationIsReady()
                }))
                alertController.addAction(UIAlertAction(title: "No", style: .Default, handler: {(action) in
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
        })
    }
    
    func donationIsReady() {
        backend.confirmVolunteerForPickupRequest(pickupRequest, completionHandler: {(result, error) -> Void in
            if let error = error {
                print(error)
            }
        })
    }
    
    func handleNotification(json: JSON) {
        let title = NotificationHelper.localizeNotificationTitle(json)
        let message = NotificationHelper.localizeNotificationMessage(json)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("dismiss", comment: ""), style: .Default, handler: nil))
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
