//
//  HomeViewController.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit

// TODO: implement

// If the user is not logged in the onboarding view will
// be presented immediately. If the user is logged in
// the user's profile and navigation options will appear.
// Later this screen could provide the current status to
// show you current information about the local needs of
// the nearest donation center and give them an option to
// share the details using the standard iOS activities.

class HomeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if AppState.sharedInstance().isUserLoggedIn {
            print("show user profile and navigation")
        }
        else {
            print("show onboarding flow")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
