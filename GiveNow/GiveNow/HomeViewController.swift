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

    @IBOutlet weak var logOutButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loginStatusDidChange:"), name: LoginStatusDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateLoginButton()
        
        if AppState.sharedInstance().isUserLoggedIn {
            print("show user profile and navigation")
        }
        else {
            print("show onboarding flow")
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginStatusDidChangeNotification, object: nil)
    }
    
    // MARK: - User Actions
    
    @IBAction func returnHome(segue: UIStoryboardSegue) {
        // do nothing
    }
    
    @IBAction func logOutButtonTapped(sender: AnyObject) {
        Backend.sharedInstance().logOut { (success, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                self.updateLoginButton()
            }
        }
    }
    
    // MARK: - Private
    
    private func updateLoginButton() {
        self.logOutButton?.hidden = !AppState.sharedInstance().isUserLoggedIn
    }
    
    // MARK: - Notifications
    
    func loginStatusDidChange(notification : NSNotification) {
        updateLoginButton()
    }

}
