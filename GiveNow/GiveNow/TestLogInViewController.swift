//
//  TestLogInViewController.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit
import Parse

class TestLogInViewController: BaseViewController {
    
    @IBOutlet weak var phoneNumberTextField: UITextField?
    @IBOutlet weak var entryCodeTextField: UITextField?
    @IBOutlet weak var statusLabel: UILabel?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PFUser.logOutInBackground()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("loginStatusDidChange:"), name: LoginStatusDidChangeNotification, object: nil)
        
        // Do any additional setup after loading the view.
        statusLabel?.text = nil
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: LoginStatusDidChangeNotification, object: nil)
    }

    // MARK: - User Actions
    
    @IBAction func sendCodeButtonTapped(sender: AnyObject) {
        self.statusLabel?.text = nil
        
        if let phoneNumber = phoneNumberTextField?.text {
            Backend.sharedInstance().sendCodeToPhoneNumber(phoneNumber, completionHandler: { (success, error) -> Void in
                if let error = error {
                    self.statusLabel?.text = error.localizedDescription
                }
                else {
                    self.statusLabel?.text = "Code sent!"
                }
            })
        }
    }
    
    @IBAction func logInButtonTapped(sender: AnyObject) {
        self.statusLabel?.text = nil
        
        if let phoneNumber = phoneNumberTextField?.text,
            let entryCode = entryCodeTextField?.text {
            
            Backend.sharedInstance().logInWithPhoneNumber(phoneNumber, codeEntry: entryCode, completionHandler: { (success, error) -> Void in
                if let error = error {
                    self.statusLabel?.text = error.localizedDescription
                }
                else {
                    self.statusLabel?.text = "Logged In!"
                }
            })
        }
    }
    
    // MARK: - User Actions
    
    func loginStatusDidChange(notification : NSNotification) {
        if AppState.sharedInstance().isUserLoggedIn {
            self.performSegueWithIdentifier("ReturnHomeSegue", sender: self)
        }
    }

}
