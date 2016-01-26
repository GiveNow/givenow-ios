//
//  ApplyToVolunteerViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/16/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

class ApplyToVolunteerViewController: BaseViewController, ModalLoginViewControllerDelegate {
    
    @IBOutlet weak var volunteeringTitleLabel: UILabel!
    @IBOutlet weak var volunteerButton: UIButton!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPendingVolunteer()
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
                        if let volunteer = volunteer {
                            if volunteer.isApproved == true {
                                self.removeFromTabBar()
                                self.removeEmbeddedViewController(self)
                            }
                        }
                    })
                    Permissions.registerForNotificationsIfNeeded()
                    self.updateViewForPendingVolunteer()
                }
            })
        }
    }
    
    private func removeFromTabBar() {
        if let tabBarController = self.tabBarController {
            let indexToRemove = 2
            if indexToRemove < tabBarController.viewControllers?.count {
                var viewControllers = tabBarController.viewControllers
                viewControllers?.removeAtIndex(indexToRemove)
                tabBarController.viewControllers = viewControllers
            }
        }
    }
    
    private func promptUserToLogIn() {
        createModalLoginView(self)
    }
    
    private func updateViewForPendingVolunteer() {
        let phoneNumberText = AppState.sharedInstance().userPhoneNumberOrReplacementText
        let titleText = String.localizedStringWithParameters("phone_number_replacement_text", phoneNumber: phoneNumberText, name: nil, code: nil)
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
                if let volunteer = volunteer {
                    if volunteer.isApproved == false {
                        self.updateViewForPendingVolunteer()
                    }
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
