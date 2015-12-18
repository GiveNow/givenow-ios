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
    
    
    @IBOutlet weak var volunteerViewControllerLabel: UILabel!
    @IBOutlet weak var volunteerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func volunteerButtonTapped(sender: AnyObject) {
        if loggedIn() == true {
//            Send in the volunteer request and update the page
        }
        else {
            //Display the login workflow
            //Once the user has logged in, send in the volunteer request and update the page
        }
    }
    
    func loggedIn() -> Bool {
        var currentUser = PFUser.currentUser()
        if currentUser != nil {
            return true
        }
        else {
            return false
        }
    }
    

    

}
