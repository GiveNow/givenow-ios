//
//  InitialViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/13/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit
import CoreLocation

class InitialViewController: BaseViewController, CLLocationManagerDelegate {
    
    var manager:CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        detectFirstLaunch()
    }
    
    // MARK: Public functions used to display appropriate workflow
    
    func displayOnboardingViewController() {
        if let vc = fetchViewControllerFromStoryboard("Onboard", storyboardIdentifier: "onboarding") as?OnboardingViewController {
            embedViewController(vc, intoView: view)
        }
    }
    
//    func displayMainViewController() {
//        if let vc = fetchViewControllerFromStoryboard("Main", storyboardIdentifier: "reveal") as? SWRevealViewController {
//            embedViewController(vc, intoView: view)
//        }
//    }
    
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
        print("Authorization changed")
        print(CLLocationManager.authorizationStatus())
        if CLLocationManager.authorizationStatus() != .NotDetermined {
            if let vc = fetchViewControllerFromStoryboard("Main", storyboardIdentifier: "reveal") as? SWRevealViewController {
                embedViewController(vc, intoView: view)
            }
        }
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
