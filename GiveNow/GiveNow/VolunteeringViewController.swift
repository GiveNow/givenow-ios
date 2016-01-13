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

class VolunteeringViewController: BaseViewController, LoginModalViewControllerDelegate {
    
    @IBOutlet weak var volunteeringTitleLabel: UILabel!
    @IBOutlet weak var volunteerButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    let backend = Backend.sharedInstance()
    
    // MARK: - Nib setup
    let loginModalViewController = LoginModalViewController(nibName: "LoginModalViewController", bundle: nil)
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMenuButton()
        checkPendingVolunteer()
    }
    
    func initializeMenuButton() {
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
    
    func successfulLogin(controller: LoginModalViewController) {
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
                    self.updateViewForPendingVolunteer()
                }
            })
        }
    }
    
    private func promptUserToLogIn() {
        //Display modal login dialogue
        loginModalViewController.modalPresentationStyle = .OverFullScreen
        loginModalViewController.modalTransitionStyle = .CrossDissolve
        loginModalViewController.delegate = self
        
        presentViewController(loginModalViewController, animated: true, completion: {})
    }
    
    private func updateViewForPendingVolunteer() {
        // replace {PhoneNumber} with actual number
        var titleText = NSLocalizedString("Volunteering - Thanks Label", comment: "")
        
        let phoneNumber = AppState.sharedInstance().userPhoneNumber
        assert(phoneNumber != nil, "Phone number should be defined")
        if let phoneNumber = phoneNumber {
            titleText = titleText.stringByReplacingOccurrencesOfString("{PhoneNumber}", withString: phoneNumber)
        }
        else {
            let defaultText = NSLocalizedString("Volunteering - Your Phone Number", comment: "")
            titleText = titleText.stringByReplacingOccurrencesOfString("{PhoneNumber}", withString: defaultText)
        }
        
        volunteeringTitleLabel.text = titleText
        volunteerButton?.setTitle(NSLocalizedString("Volunteering - Thanks Button", comment: ""), forState: .Normal)
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
        
        volunteeringTitleLabel.text = NSLocalizedString("Volunteering - Title Label", comment: "")
        volunteerButton.setTitle(NSLocalizedString("Volunteering - Title Button", comment: ""), forState: .Normal)
        volunteerButton.hidden = false
    }

}
