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
    
    //Number validation
    let phoneFormatter = NBAsYouTypeFormatter(regionCode: Backend.sharedInstance().regionCodeForCurrentLocale())
    var previousFormattedText = "+"

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

    @IBAction func phoneTextFieldEditingChanged(sender: AnyObject) {
        
        if entryMode == .PhoneNumber {
            if let inputField = sender as? UITextField,
                inputText = inputField.text
            {
                let strippedInputText = strippedPhoneNumber(inputText)
                
                let currentSelectedRange = inputField.selectedTextRange
                
                let formattedText = phoneFormatter.inputString(strippedInputText)
                
                if let selectedRange = currentSelectedRange where previousFormattedText == formattedText { //Failed delete on nonumeric char
                    let (adjustedRange, adjustedInputString) = self.deleteNumberBeforeSelectedRange(inputField, startText: inputText, selectedRange: selectedRange)
                    let strippedAdjustedString = strippedPhoneNumber(adjustedInputString)
                    let adjustedFormattedText = phoneFormatter.inputString(strippedAdjustedString)
                    inputField.text = adjustedFormattedText
                    
                    if let updatedRange = adjustedRange {
                        self.restoreSelectedRange(inputField, startText: adjustedFormattedText, endText: adjustedFormattedText, selectedRange: updatedRange)
                    }
                    
                    previousFormattedText = adjustedFormattedText
                } else {
                    inputField.text = formattedText
                    
                    if let selectedRange = currentSelectedRange {
                        self.restoreSelectedRange(inputField, startText: inputText, endText: formattedText, selectedRange: selectedRange)
                    }
                    
                    previousFormattedText = formattedText
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
        textField.text = phoneFormatter.inputString(phoneNumber)
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
                return
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
        guard let phoneEntry = textField.text else {
            return
        }
        if phoneEntry.characters.first != "+" {
            detailLabel.text = NSLocalizedString("phone_number_verification_error_no_country_code", comment: "")
        }
        else {
           detailLabel.text = NSLocalizedString("phone_number_verification_error_number_invalid", comment: "")
        }
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
    
    // MARK: Phone Number Validation
    
    private func deleteNumberBeforeSelectedRange(textField: UITextField, startText: String, selectedRange : UITextRange) -> (adjustedRange: UITextRange?, adjustedText: String) {
        //get previous cursor position
        let start = textField.beginningOfDocument
        let cursorOffset = textField.offsetFromPosition(start, toPosition:selectedRange.start)
        
        //Loop until we find a digit
        var currentOffset = cursorOffset
        var index = startText.startIndex.advancedBy(currentOffset - 1, limit: startText.endIndex)
        var updatedText = startText
        while index >= startText.startIndex {
            if startText.characters[index] > "0" || startText.characters[index] < "9" { //digit
                updatedText.removeAtIndex(index)
                break
            }
            
            currentOffset = currentOffset - 1
            index = startText.startIndex.advancedBy(currentOffset, limit: startText.endIndex)
        }
        
        var updatedRange : UITextRange?
        if let newPosition = textField.positionFromPosition(textField.beginningOfDocument, offset:currentOffset - 1) {
            updatedRange = textField.textRangeFromPosition(newPosition, toPosition:newPosition)
        }
        
        return (updatedRange, updatedText)
    }
    
    private func restoreSelectedRange(textField: UITextField, startText: String, endText: String, selectedRange : UITextRange) {
        // get previous cursor position
        let start = textField.beginningOfDocument
        let cursorOffset = textField.offsetFromPosition(start, toPosition:selectedRange.start)
        let currentLength = startText.characters.count
        
        // if cursor was not at the end of the text restore its position
        if cursorOffset != currentLength {
            let lengthDelta = endText.characters.count - currentLength
            let newCursorOffset = max(0, min(endText.characters.count, cursorOffset + lengthDelta))
            if let newPosition = textField.positionFromPosition(textField.beginningOfDocument, offset:newCursorOffset) {
                let newRange = textField.textRangeFromPosition(newPosition, toPosition:newPosition)
                textField.selectedTextRange = newRange
            }
        }
    }
    
    private func strippedPhoneNumber(phoneNumberString: String) -> String {
        let digitsPlusCharacterSet = NSCharacterSet(charactersInString: "+0123456789").invertedSet
        let strippedPhoneNumberString = phoneNumberString.componentsSeparatedByCharactersInSet(digitsPlusCharacterSet).joinWithSeparator("")
        return strippedPhoneNumberString
    }
}

