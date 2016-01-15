//
//  VolunteeringViewController.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit
import Parse

// TODO: implement
// See https://github.com/GiveNow/givenow-ios/issues/7
// See https://github.com/GiveNow/givenow-ios/issues/8

class VolunteeringViewController: BaseViewController, ModalLoginViewControllerDelegate {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var volunteeringTitleLabel: UILabel!
    @IBOutlet weak var volunteerButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMenuButton(menuButton)
        checkPendingVolunteer()
        localizeStrings()
    }
    
    func localizeStrings() {
        navItem.title = NSLocalizedString("title_volunteer", comment: "")
    }
    
    // MARK: - User Actions
    
    @IBAction func volunteerButtonTapped(sender: AnyObject) {
        if AppState.sharedInstance().isUserRegistered {
            createVolunteer()
        }
        else {
            promptUserToLogIn()
        }
    }
    
    @IBAction func loginViewDismissed(segue: UIStoryboardSegue) {
        // do nothing
    }
    
    func modalViewDismissedWithResult(controller: ModalLoginViewController) {
        createVolunteer()
    }

    // MARK: - Private
    
    private func createVolunteer() {
        if let user = User.currentUser() {
            Backend.sharedInstance().saveVolunteer(user, completionHandler: { (volunteer, error) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    // after successful submission
                    self.backend.fetchVolunteerForUser(user, completionHandler: {(volunteer, user) -> Void in
                        if volunteer != nil && volunteer!.isApproved == true {
                            print("Should show dashboard")
                        }
                        else {
                            print("Should show pending volunteer")
                        }
                    })
                    self.updateViewForPendingVolunteer()
                }
            })
        }
    }
    
    private func promptUserToLogIn() {
        createModalLoginView(self)
    }
    
    private func updateViewForPendingVolunteer() {
        // replace {PhoneNumber} with actual number
        var titleText = NSLocalizedString("volunteer_label_user_has_applied", comment: "")
        
        let phoneNumber = AppState.sharedInstance().userPhoneNumber
        assert(phoneNumber != nil, "Phone number should be defined")
        if let phoneNumber = phoneNumber {
            titleText = titleText.stringByReplacingOccurrencesOfString("{PhoneNumber}", withString: phoneNumber)
        }
        else {
            let defaultText = NSLocalizedString("volunteer_your_phone_number", comment: "")
            titleText = titleText.stringByReplacingOccurrencesOfString("{PhoneNumber}", withString: defaultText)
        }
        
        volunteeringTitleLabel.text = titleText
        volunteerButton?.setTitle(NSLocalizedString("volunteer_button_user_has_applied", comment: ""), forState: .Normal)
        volunteerButton?.backgroundColor = UIColor.lightGrayColor()
        volunteerButton.hidden = false
    }
    
    private func checkPendingVolunteer() {
        volunteeringTitleLabel.text = ""
        volunteerButton.hidden = true
        volunteerButton.setTitle("", forState: .Normal)
        if AppState.sharedInstance().isUserRegistered {
            let user = User.currentUser()!
            backend.fetchVolunteerForUser(user, completionHandler: {(volunteer, user) -> Void in
                if volunteer != nil && volunteer!.isApproved == false {
                    self.updateViewForPendingVolunteer()
                }
                else {
                    self.updateViewForApplicant()
                }
            })
        }
        else {
            self.updateViewForApplicant()
        }
    }
    
    private func updateViewForApplicant() {
        
        volunteeringTitleLabel.text = NSLocalizedString("volunteer_label_user_has_not_applied", comment: "")
        volunteerButton.setTitle(NSLocalizedString("volunteer_button_user_has_not_applied", comment: ""), forState: .Normal)
        volunteerButton.hidden = false
    }

}
