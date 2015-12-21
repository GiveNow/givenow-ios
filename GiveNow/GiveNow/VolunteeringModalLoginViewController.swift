//
//  VolunteeringModalLoginViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 12/18/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit

public enum VolunteeringEntryMode : Int {
    case None = 0
    case PhoneNumber
    case ConfirmationCode
}

class VolunteeringModalLoginViewController: UIViewController {
    
    @IBOutlet weak var modalTitle: UILabel?
    @IBOutlet weak var modalDetails: UILabel?
    @IBOutlet weak var entryTextField: UITextField?
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var submitButton: UIButton?
    
    private var _entryMode : VolunteeringEntryMode = .None
    
    var entryMode : VolunteeringEntryMode {
        get {
            return _entryMode
        }
        set {
            if newValue != _entryMode {
                _entryMode = newValue
                
                // clear out the text when changing entry modes
                self.entryTextField?.text = nil
                self.updateTextForEntryMode(_entryMode)
            }
        }
    }
    
    var phoneNumber : String?
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        entryMode = .PhoneNumber
    }
    
    override func viewDidAppear(animated: Bool) {
        validateSubmitButton()
        self.entryTextField?.becomeFirstResponder()
    }

    // MARK: User Actions
    
    @IBAction func loginCancelled(sender: AnyObject) {
        performSegueWithIdentifier("loginViewDismissed", sender: nil)
    }
    
    @IBAction func phoneTextFieldEditingChanged(sender: AnyObject) {
        validateSubmitButton()
    }
    
    @IBAction func submitButtonTapped(sender: AnyObject) {
        guard let entryText = entryTextField?.text else {
            assert(false, "Entry text is required")
            return
        }
        
        if entryMode == .PhoneNumber {
            sendPhoneNumber(entryText)
        }
        else if entryMode == .ConfirmationCode {
            if let phoneNumber = self.phoneNumber {
                logInWithPhoneNumber(phoneNumber, codeEntry: entryText)
            }
            else {
                assert(false, "Phone number should always be defined")
            }
        }
    }
    
    // MARK: Private
    
    private func disableSubmitButton() {
        guard let submitButton = submitButton else {
            return
        }
        
        submitButton.enabled = false
        submitButton.titleLabel?.textColor = UIColor.lightGrayColor()
    }
    
    private func enableSubmitButton() {
        guard let submitButton = submitButton else {
            return
        }

        submitButton.enabled = true
        submitButton.titleLabel?.textColor = UIColor.whiteColor()
    }
    
    private func validateSubmitButton() {
        guard let phoneNumberText = entryTextField?.text else {
            disableSubmitButton()
            return
        }
        
        // A phone number should include the country code which is 1 for the United States.
        // Typically the country code is assumed so perhaps it can be added automatically.
        
        if entryMode == .PhoneNumber &&
            (phoneNumberText.characters.count == 10 ||
            phoneNumberText.characters.count == 11) {
            enableSubmitButton()
        }
        else if entryMode == .ConfirmationCode && phoneNumberText.characters.count == 4 {
            enableSubmitButton()
        }
        else {
            disableSubmitButton()
        }
    }
    
    private func sendPhoneNumber(phoneNumber: String) {
        Backend.sharedInstance().sendCodeToPhoneNumber(phoneNumber, completionHandler: { (success, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                // hold onto the phone number to use when logging in
                self.phoneNumber = phoneNumber
                self.entryMode = .ConfirmationCode
            }
        })
    }
    
    private func logInWithPhoneNumber(phoneNumber: String, codeEntry: String) {
        Backend.sharedInstance().logInWithPhoneNumber(phoneNumber, codeEntry: codeEntry, completionHandler: { (success, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                self.performSegueWithIdentifier("successfulLogin", sender: nil)
            }
        })
    }
    
    private func updateTextForEntryMode(entryMode : VolunteeringEntryMode) {
        guard let modalTitle = modalTitle,
            let modalDetails = modalDetails,
            let cancelButton = cancelButton,
            let submitButton = submitButton else {
            assert(false, "Outlets are required")
            return
        }
        
        if entryMode == .PhoneNumber {
            modalTitle.text = NSLocalizedString("Volunteering - Phone Number Modal Title", comment: "")
            modalDetails.text = NSLocalizedString("Volunteering - Phone Number Modal Details", comment: "")
            cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), forState: .Normal)
            submitButton.setTitle(NSLocalizedString("Submit", comment: "Submit"), forState: .Normal)
        }
        else if entryMode == .ConfirmationCode {
            modalTitle.text = NSLocalizedString("Volunteering - Confirmation Number Modal Title", comment: "")
            modalDetails.text = NSLocalizedString("Volunteering - Confirmation Number Modal Details", comment: "")
            cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel"), forState: .Normal)
            submitButton.setTitle(NSLocalizedString("Submit", comment: "Submit"), forState: .Normal)
        }
    }

}
