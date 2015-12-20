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
    
    // Assume this will be retrieved from logged in user object
    var phoneNumber: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLabels()
    }
    
    func initializeLabels() {
        volunteeringTitleLabel?.text = NSLocalizedString("Volunteering - Title Label", comment: "")
        volunteerButton?.setTitle(NSLocalizedString("Volunteering - Title Button", comment: ""), forState: .Normal)
    }
    
    @IBAction func volunteerButtonTapped(sender: AnyObject) {
        if AppState.sharedInstance().isUserLoggedIn {
            submitVolunteerApplicationRequest()
        }
        else {
            askUserToLogin()
        }
    }
    
    func submitVolunteerApplicationRequest() {
        //ToDo: Create object, submit to back end
        
        // after successful submission
        updateViewAfterSuccessfulSubmission()
    }
    
    func askUserToLogin() {
        //Display modal login dialogue
        performSegueWithIdentifier("logIn", sender: nil)
    }
    
    func updateViewAfterSuccessfulSubmission() {
        // replace {PhoneNumber} with actual number
        var titleText = NSLocalizedString("Volunteering - Thanks Label", comment: "")
        
        
        assert(self.phoneNumber != nil, "phone number should be defined")
        if let phoneNumber = self.phoneNumber {
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
    
    @IBAction func loginViewDismissed(segue: UIStoryboardSegue) {
    }
    
    @IBAction func successfulLogin(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? VolunteeringModalLoginViewController {
            self.phoneNumber = vc.phoneNumber
        }
        submitVolunteerApplicationRequest()
    }

    func isLoggedIn() -> Bool {
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            return true
        } else {
           return false
        }
    }

}
