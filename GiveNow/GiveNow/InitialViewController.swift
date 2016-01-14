//
//  InitialViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/13/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        detectFirstLaunch()
        super.viewDidAppear(true)
    }
    
    func detectFirstLaunch(){
        let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
        if !firstLaunch {
            displayOnboardingViewController()
        }
        else {
            displayMainViewController()
        }
    }
    
    func displayOnboardingViewController() {
        let storyboard = UIStoryboard(name: "Onboard", bundle: nil)
        let onboardingViewController = storyboard.instantiateViewControllerWithIdentifier("onboarding") as! OnboardingViewController
        
        addChildViewController(onboardingViewController)
        view.addSubview(onboardingViewController.view)
        onboardingViewController.didMoveToParentViewController(self)
    }
    
    func displayMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let revealViewController = storyboard.instantiateViewControllerWithIdentifier("reveal") as! SWRevealViewController
        addChildViewController(revealViewController)
        view.addSubview(revealViewController.view)
        revealViewController.didMoveToParentViewController(self)
    }

}
