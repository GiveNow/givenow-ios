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
    case ConfirmationCode
}

class LoginModalViewController: UIViewController {

    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    private var _entryMode : EntryMode = .None
    
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
    
    // MARK: Private
    
    private func updateViewForEntryMode(entryMode: EntryMode) {
        guard let instructionsLabel = instructionsLabel,
            let textField = textField,
            let detailLabel = detailLabel,
            let backButton = backButton,
            let doneButton = doneButton else {
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
        case .ConfirmationCode:
            textField.text = nil
            instructionsLabel.text = NSLocalizedString("Volunteering - Confirmation Number Modal Title", comment: "")
            detailLabel.text = NSLocalizedString("Volunteering - Confirmation Number Modal Details", comment: "")
            backButton.hidden = false
        default:
            print("No action")
        }
    }

}
