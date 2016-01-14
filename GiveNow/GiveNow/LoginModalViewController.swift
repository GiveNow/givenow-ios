//
//  LoginModalViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/12/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

public enum EntryMode : Int {
    case None = 0
    case PhoneNumber
    case InvalidPhoneNumber
    case ConfirmationCode
}

protocol LoginModalViewControllerDelegate{
    func successfulLogin(controller:LoginModalViewController)
}

class LoginModalViewController: UIViewController {
    
    var delegate:LoginModalViewControllerDelegate!

    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    private var _entryMode : EntryMode = .None
    
    var phoneNumber:String!
    
    let backend = Backend.sharedInstance()
    
    var entryMode : EntryMode {
        get {
           return _entryMode
        }
        set {
            if newValue != _entryMode {
                _entryMode = newValue
                self.updateViewForEntryMode(_entryMode)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatButton(backButton, imageName: "arrow-back")
        formatButton(doneButton, imageName: "checkmark")
        entryMode = .PhoneNumber
    }
    
    func formatButton(button: UIButton, imageName: String){
        button.setImage(UIImage(named: imageName)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.tintColor = UIColor.whiteColor()
    }
    
    @IBAction func backgroundTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {})
    }
    
    // MARK: User Actions
    
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        guard let entryText = textField?.text else {
            assert(false, "Entry text is required")
            return
        }
        
        if entryMode == .PhoneNumber || entryMode == .InvalidPhoneNumber {
            validatePhoneNumber(entryText)
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
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        entryMode = .PhoneNumber
        textField.text = phoneNumber
    }
    
    
    // MARK: Private
    
    private func validatePhoneNumber(entryText: String) {
        if backend.isValidPhoneNumber(entryText) {
            sendPhoneNumber(entryText)
        }
        else {
            entryMode = .InvalidPhoneNumber
            updateViewForEntryMode(entryMode)
        }
    }
    
    private func updateViewForEntryMode(entryMode: EntryMode) {
        guard let instructionsLabel = instructionsLabel,
            let textField = textField,
            let detailLabel = detailLabel,
            let backButton = backButton
            else {
                assert(false, "Outlets are required")
        }
        
        switch entryMode {
        case .PhoneNumber:
            if let countryCallingCode = backend.phoneCountryCodeForPhoneNumberCurrentLocale() {
                textField.text = "+\(countryCallingCode)"
            }
            else {
                textField.text = nil
            }
            instructionsLabel.text = NSLocalizedString("Volunteering - Phone Number Modal Title", comment: "")
            detailLabel.text = NSLocalizedString("Volunteering - Phone Number Modal Details", comment: "")
            backButton.hidden = true
        case .InvalidPhoneNumber:
            instructionsLabel.text = "Please enter a valid phone number"
            detailLabel.text = ""
            backButton.hidden = true
        case .ConfirmationCode:
            textField.text = nil
            instructionsLabel.text = NSLocalizedString("Volunteering - Confirmation Number Modal Title", comment: "")
            detailLabel.text = NSLocalizedString("Volunteering - Confirmation Number Modal Details", comment: "")
            backButton.hidden = false
        default:
            print("No action")
        }
    }
    
    private func sendPhoneNumber(phoneNumber: String) {
        backend.sendCodeToPhoneNumber(phoneNumber, completionHandler: { (success, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                // hold onto the phone number to use when logging in
                self.phoneNumber = phoneNumber
                self.textField.placeholder = "5555"
                self.entryMode = .ConfirmationCode
            }
        })
    }
    
    private func logInWithPhoneNumber(phoneNumber: String, codeEntry: String) {
        backend.logInWithPhoneNumber(phoneNumber, codeEntry: codeEntry, completionHandler: { (success, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                self.dismissViewControllerAnimated(true, completion: {() -> Void in
                    self.delegate.successfulLogin(self)
                })
            }
        })
    }

}
