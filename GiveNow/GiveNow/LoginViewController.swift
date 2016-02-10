//
//  LoginViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/12/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit
import libPhoneNumber_iOS

public enum EntryMode : Int {
    case None = 0
    case PhoneNumber
    case ConfirmationCode
}

protocol LoginViewControllerDelegate{
    func successfulLogin(controller:LoginViewController)
}

class LoginViewController: BaseViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var delegate:LoginViewControllerDelegate!
    var isModal:Bool!

    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var _entryMode : EntryMode = .None
    
    var phoneNumber:String!
    
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
        configure()
    }
    
    func configure() {
        validateSubmitButton()
        addTapGesture()
        updateViewForEntryMode(entryMode)
        hideActivityIndicator()
        textField?.becomeFirstResponder()
    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: Selector("viewTapped:"))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func viewTapped(sender: UIGestureRecognizer? = nil) {
        view.endEditing(true)
    }
    
    let phoneFormatter = NBAsYouTypeFormatter(regionCode: Backend.sharedInstance().regionCodeForCurrentLocale())
    @IBAction func phoneTextFieldEditingChanged(sender: AnyObject) {
        
        /*
        We have the adjusted text after user performed an editing action, eg (Backspace, Add a character, Select and delete, Select and add)
        Need to get the raw numbers and plus sign out of this text and format it
        
        Complication: set the text to the formatted text forgets the cursor position we must save it and restore it adjusting for differences between
        formatted text and the previous formatted text
        
        Edge case when the user performs a backspace event on a non-numeric character the output of the formatter is going to be the same as before 
        making it appear as if backspace failed, instead we want to find the number before the current cursor and delete it, perform our formatting 
        and restore the cursor
        
        Since we require the plus sign prefix we should not allow users to delete it
        */
        
        if entryMode == .PhoneNumber {
            if let inputField = sender as? UITextField,
                inputText = inputField.text
            {
                //Strip the phone number of previous formatting and invalid chars
                let strippedInputText = strippedPhoneNumber(inputText)
                
                //Save the cursor state to restore after
                let previousSelectedRange = inputField.selectedTextRange
                
                //Format the phone number
                let formattedText = phoneFormatter.inputString(strippedInputText)
                inputField.text = formattedText
                
                if let selectedRange = previousSelectedRange {

                    // get previous cursor position
                    let start = inputField.beginningOfDocument
                    let cursorOffset = inputField.offsetFromPosition(start, toPosition:selectedRange.start)
                    let currentLength = inputText.characters.count
                    
                    // if cursor was not at the end of the text restore its position
                    if cursorOffset != currentLength {
                        let lengthDelta = formattedText.characters.count - currentLength
                        let newCursorOffset = max(0, min(formattedText.characters.count, cursorOffset + lengthDelta))
                        if let newPosition = inputField.positionFromPosition(textField.beginningOfDocument, offset:newCursorOffset) {
                            let newRange = inputField.textRangeFromPosition(newPosition, toPosition:newPosition)
                            inputField.selectedTextRange = newRange
                        }
                    }
                }
            }
        }
        
        validateSubmitButton()
    }
    
    func formatButton(button: UIButton, imageName: String){
        button.setImage(UIImage(named: imageName)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.tintColor = UIColor.whiteColor()
    }
    
    // MARK: User Actions
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        guard let entryText = textField?.text else {
            assert(false, "Entry text is required")
            return
        }
        
        if entryMode == .PhoneNumber {
            let phoneNumberDigits = self.strippedPhoneNumber(entryText)
            validatePhoneNumber(phoneNumberDigits)
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
            updateViewForInvalidPhoneNumber()
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
            instructionsLabel.text = NSLocalizedString("phone_number_verification_title", comment: "")
            detailLabel.text = NSLocalizedString("phone_number_disclaimer", comment: "")
            backButton.hidden = true
        case .ConfirmationCode:
            textField.text = nil
            instructionsLabel.text = NSLocalizedString("confirmation_code_title", comment: "")
            detailLabel.text = NSLocalizedString("validate_sms_code", comment: "")
            backButton.hidden = false
        default:
            print("No action")
        }
    }
    
    private func updateViewForInvalidPhoneNumber() {
        detailLabel.text = NSLocalizedString("phone_number_verification_error_number_invalid", comment: "")
        backButton.hidden = true
    }
    
    private func updateViewForInvalidConfirmationCode() {
        instructionsLabel.text = NSLocalizedString("confirmation_code_error", comment: "")
        detailLabel.text = ""
    }
    
    private func sendPhoneNumber(phoneNumber: String) {
        showActivityIndicator()
        backend.sendCodeToPhoneNumber(phoneNumber, completionHandler: { (success, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                self.hideActivityIndicator()
                // hold onto the phone number to use when logging in
                self.phoneNumber = phoneNumber
                self.textField.placeholder = "5555"
                self.entryMode = .ConfirmationCode
            }
        })
    }
    
    func showActivityIndicator() {
        doneButton.hidden = true
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        doneButton.hidden = false
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }
    
    private func logInWithPhoneNumber(phoneNumber: String, codeEntry: String) {
        showActivityIndicator()
        backend.logInWithPhoneNumber(phoneNumber, codeEntry: codeEntry, completionHandler: { (success, error) -> Void in
            if let error = error {
                self.hideActivityIndicator()
                self.updateViewForInvalidConfirmationCode()
                print(error.localizedDescription)
            }
            else {
                if self.isModal == true {
                    self.dismissViewControllerAnimated(true, completion: {() -> Void in
                        self.delegate.successfulLogin(self)
                    })
                }
                else {
                    self.delegate.successfulLogin(self)
                }
            }
        })
    }
    
    private func validateSubmitButton() {
        guard let phoneNumberText = textField?.text else {
            disableDoneButton()
            return
        }
        
        
        let phoneNumberDigitsText = self.strippedPhoneNumber(phoneNumberText)
        
        // A phone number should include the country code which is 1 for the United States.
        // Typically the country code is assumed so perhaps it can be added automatically.
        
        if entryMode == .PhoneNumber &&
            (phoneNumberDigitsText.characters.count >= 10 &&
                phoneNumberDigitsText.characters.count <= 12) {
                    enableDoneButton()
        }
        else if entryMode == .ConfirmationCode && phoneNumberText.characters.count == 4 {
            enableDoneButton()
        }
        else {
            disableDoneButton()
        }
    }
    
    private func disableDoneButton() {
        guard let doneButton = doneButton else {
            return
        }
        
        doneButton.enabled = false
        doneButton.titleLabel?.textColor = UIColor.lightGrayColor()
    }
    
    private func enableDoneButton() {
        guard let doneButton = doneButton else {
            return
        }
        
        doneButton.enabled = true
        doneButton.titleLabel?.textColor = UIColor.whiteColor()
    }
    
    //want stripped offset
    
    //formatted text is +1-845-709|-1552
    //stripped length is +18457091552
    
    ///+1-845-709|-1552
    ///stripped length is +1845709|1552
    ///return 8
    
    ///+1-84|5-709-1552
    ///stripped length is +184|57091552
    ///return 4
    
    ///unformatted characters in range
    
    private func unformattedCharactersBeforeIndex(input: String, index: Int) -> Int {
        let stringIndex = input.startIndex.advancedBy(index, limit: input.endIndex)
        let filteredCharacters = input.substringToIndex(stringIndex).characters.filter { "+0123456789".containsString("\($0)") }
        return filteredCharacters.count
    }
    
    private func strippedPhoneNumber(phoneNumberString: String) -> String {
        let digitsPlusCharacterSet = NSCharacterSet(charactersInString: "+0123456789").invertedSet
        let strippedPhoneNumberString = phoneNumberString.componentsSeparatedByCharactersInSet(digitsPlusCharacterSet).joinWithSeparator("")
        return strippedPhoneNumberString
    }
}

