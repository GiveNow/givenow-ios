//
//  VolunteeringModalLoginViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 12/18/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit

class VolunteeringModalLoginViewController: UIViewController {
    
    var phoneNumberSubmitted:Bool!
    
    @IBOutlet weak var modalTitle: UILabel!
    @IBOutlet weak var modalDetails: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        initializeText()
        phoneNumberSubmitted = false
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        validateSubmitButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeText() {
        //To Do: Localize this
        modalTitle.text = "Add a phone number"
        modalDetails.text = "We'll contact you at this number with details about volunteering. Don't worry, we won't share it with anyone!"
        cancelButton.setTitle("Cancel", forState: .Normal)
        submitButton.setTitle("Submit", forState: .Normal)
    }
    
    @IBAction func loginCancelled(sender: AnyObject) {
        performSegueWithIdentifier("loginViewDismissed", sender: nil)
    }
    
    @IBAction func phoneTextFieldEditingChanged(sender: AnyObject) {
        validateSubmitButton()
    }
    
    func disableSubmitButton() {
        submitButton.enabled = false
        submitButton.titleLabel!.textColor = UIColor.lightGrayColor()
    }
    
    func enableSubmitButton() {
        submitButton.enabled = true
        submitButton.titleLabel!.textColor = UIColor.whiteColor()
    }
    
    func validateSubmitButton() {
        if phoneNumberSubmitted == false && phoneTextField.text?.characters.count == 10 {
            enableSubmitButton()
        }
        else if phoneTextField.text?.characters.count == 4 {
            enableSubmitButton()
        }
        else {
            disableSubmitButton()
        }
    }
    
    
    @IBAction func submitButtonTapped(sender: AnyObject) {
        print("submit tapped")
        if let phoneNumber = phoneTextField?.text {
            if self.phoneNumberSubmitted == false {
                sendCodeToPhoneNumber(phoneNumber)
            }
            else {
                
            }
        }
        
        // Send SMS to Parse
    }
    
    func sendCodeToPhoneNumber(phoneNumber: String) {
        Backend.sharedInstance().sendCodeToPhoneNumber(phoneNumber, completionHandler: { (success, error) -> Void in
            if let error = error {
                print(error)
            }
            else {
                self.updateDialogueForCodeEntry()
            }
        })
    }
    
    func updateDialogueForCodeEntry() {
        phoneNumberSubmitted = true
        //To Do: Localize this
        modalTitle.text = "Enter confirmation code"
        modalDetails.text = "You should have gotten a 4-digit confirmation code. Enter it here to complete the signup!"
        cancelButton.setTitle("Cancel", forState: .Normal)
        submitButton.setTitle("Submit", forState: .Normal)
    }
    
    func logInWithPhoneNumber(phoneNumber: String, entryCode: String) {
        Backend.sharedInstance().logInWithPhoneNumber(phoneNumber, codeEntry: entryCode, completionHandler: { (success, error) -> Void in
            if let error = error {
                print(error)
            }
            else {
                self.performSegueWithIdentifier("successfulLogin", sender: nil)
            }
        })
    }

}
