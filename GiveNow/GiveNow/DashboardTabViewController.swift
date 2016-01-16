//
//  DashboardTabViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/10/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

class DashboardTabViewController: UITabBarController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    
    let backend = Backend.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMenuButton()
        localizeStrings()
        showVolunteerApplicationIfNecessary()
    }
    
    private func localizeStrings() {
        navItem.title = NSLocalizedString("title_volunteer", comment: "")
        
        // Need to localize all tab bar items on load; if this is done within the individual view controllers they are not loaded until those tabs are opened
        if tabBar.items != nil {
            let tabTitles = [NSLocalizedString("dashboard_pickup_requests_tabbaritem", comment: ""),NSLocalizedString("dashboard_dashboard_tabbaritem", comment: "")]
            for i in 0...tabBar.items!.count - 1 {
                let tabBarItem = tabBar.items![i]
                tabBarItem.title = tabTitles[i]
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func initializeMenuButton() {
        if self.revealViewController() != nil {
            if let menuImage = UIImage(named: "menu") {
                self.menuButton.image = menuImage.imageWithRenderingMode(.AlwaysTemplate)
                self.menuButton.tintColor = UIColor.whiteColor()
            }
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    private func showVolunteerApplicationIfNecessary() {
        if AppState.sharedInstance().isUserRegistered {
            let user = User.currentUser()!
            backend.fetchVolunteerForUser(user, completionHandler: {(volunteer, error) -> Void in
                if volunteer == nil || volunteer?.isApproved != true {
                    self.showVolunteerApplication()
                }
            })
        }
        else {
            self.showVolunteerApplication()
        }
    }
    
    private func showVolunteerApplication() {
        guard let volunteerApplicationController = storyboard?.instantiateViewControllerWithIdentifier("volunteerApplication") as? ApplyToVolunteerViewController else {
            print("Could not find storyboard")
            return
        }
        addChildViewController(volunteerApplicationController)
        volunteerApplicationController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(volunteerApplicationController.view)
        volunteerApplicationController.didMoveToParentViewController(self)
    }
    
//    func addPendingDonationChildView() {
//        if storyboard != nil {
//            searchController.searchBar.hidden = true
//            let pendingDonationViewController = storyboard!.instantiateViewControllerWithIdentifier("pendingDonationView") as! MyPendingDonationViewController
//            pendingDonationViewController.pickupRequest = newPickupRequest
//            addChildViewController(pendingDonationViewController)
//            pendingDonationViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
//            view.addSubview(pendingDonationViewController.view)
//            pendingDonationViewController.didMoveToParentViewController(self)
//        }
//    }

}
