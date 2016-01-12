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

class VolunteeringViewController: BaseViewController {
    
    @IBOutlet weak var volunteeringTitleLabel: UILabel?
    @IBOutlet weak var volunteerButton: UIButton?
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMenuButton()
        initializeLabels()
    }
    
    func initializeMenuButton() {
        if self.revealViewController() != nil {
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
    
    @IBAction func successfulLogin(segue: UIStoryboardSegue) {
        createVolunteer()
    }

    // MARK: - Private
    
    func initializeLabels() {
        volunteeringTitleLabel?.text = NSLocalizedString("Volunteering - Title Label", comment: "")
        volunteerButton?.setTitle(NSLocalizedString("Volunteering - Title Button", comment: ""), forState: .Normal)
    }
    
    func createVolunteer() {
        if let user = User.currentUser() {
            Backend.sharedInstance().saveVolunteer(user, completionHandler: { (volunteer, error) -> Void in
                if let error = error {
                    print(error.localizedDescription)
                }
                else {
                    // after successful submission
                    self.updateViewAfterCreatingVolunteer()
                }
            })
        }
    }
    
    func promptUserToLogIn() {
        //Display modal login dialogue
        performSegueWithIdentifier("logIn", sender: nil)
    }
    
    func updateViewAfterCreatingVolunteer() {
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
        
        volunteeringTitleLabel?.text = titleText
        volunteerButton?.setTitle(NSLocalizedString("Volunteering - Thanks Button", comment: ""), forState: .Normal)
        volunteerButton?.backgroundColor = UIColor.lightGrayColor()
    }

}
