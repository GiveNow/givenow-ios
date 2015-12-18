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
    
    @IBOutlet weak var volunteeringTitleLabel: UILabel!
    @IBOutlet weak var volunteerButton: UIButton!
    
    // Assume this will be retrieved from logged in user object
    var userPhoneNumber:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLabels()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeLabels() {
        //ToDo: Localize
        volunteeringTitleLabel.text = "Want to volunteer to pick up donations? The only thing you need is a ar and some spare time!"
        volunteerButton.setTitle("I want to volunteer!", forState: .Normal)
    }
    
    
    @IBAction func volunteerButtonTapped(sender: AnyObject) {
        
        // if user logged in, submit volunteer request
        // and then update the label and text
        if AppState.sharedInstance().isUserLoggedIn {
            submitVolunteerApplicationRequest()
        }
            
        // if not, do login flow and then submit volunteer request
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
        
        // after successful login
        submitVolunteerApplicationRequest()
    }
    
    func updateViewAfterSuccessfulSubmission() {
        //ToDo: Localize
        volunteeringTitleLabel.text = "Thanks for applying to volunteer! We'll contact you soon at \(userPhoneNumber)"
        volunteerButton.setTitle("You applied to volunteer", forState: .Normal)
        volunteerButton.backgroundColor = UIColor.lightGrayColor()
        
    }
    
//// Could use this to check if user is logged in
//    func isLoggedIn() -> Bool {
//        let currentUser = PFUser.currentUser()
//        if currentUser != nil {
//            return true
//        } else {
//           return false
//        }
//    }
    
    
    
    
    

}
