//
//  OnboardingViewController.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit

// TODO: implement
// See https://github.com/GiveNow/givenow-ios/issues/4
// See https://github.com/GiveNow/givenow-ios/issues/5

class OnboardingViewController: BaseViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var pageControl : UIPageControl?
    
    typealias OnboardingText = (title: String, details: String)
    
    struct CellConfig {
        let color : UIColor
        let text : OnboardingText
        let imageName : String
    }
    
    struct Colors {
        //Color Primary
        static let OnboardingColor1 = UIColor(red: 0.0/255.0, green: 185.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        //Color Primary Dark
        static let OnboardingColor2 = UIColor(red: 10.0/255.0, green: 137.0/255.0, blue: 167.0/255.0, alpha: 1.0)
        static let OnboardingColor3 = UIColor(red: 0.0/255.0, green: 185.0/255.0, blue: 230.0/255.0, alpha: 1.0)
        static let OnboardingColor4 = UIColor(red: 3.0/255.0, green: 155.0/255.0, blue: 229.0/255.0, alpha: 1.0)
        //Accent color
        static let SignInColor = UIColor(red: 102.0/255.0, green: 187.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    }
    
    
    //TODO: Localize
    static let onboardingTextArray : [OnboardingText]  = [
        ("Welcome to GiveNow.",
        "GiveNow lets you donate from anywhere."),
        
        ("We show you what's needed most in your area.",
        "You select what you want to donate."),
        
        ("Tell us where to pick it up.",
        "Simply pinpoint a spot on the map. You can even add special instructions like apartment numbers or gate codes."),
        
        ("We take care of the rest.",
        "A trusted volunteer driver will pick up your donation. We'll contact you to coordinate the pickup.")
    ]
    
    let onboardingConfigs = [
        CellConfig(color: Colors.OnboardingColor1, text: onboardingTextArray[0], imageName: "round_icon"),
        CellConfig(color: Colors.OnboardingColor2, text: onboardingTextArray[1], imageName: "onboarding_2_image"),
        CellConfig(color: Colors.OnboardingColor3, text: onboardingTextArray[2], imageName:  "onboarding_3_image"),
        CellConfig(color: Colors.OnboardingColor4, text: onboardingTextArray[3], imageName: "onboarding_4_image"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.setNavigationBarHidden(true, animated: true)

        // Do any additional setup after loading the view.
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return self.view.frame.size
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < onboardingConfigs.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("OnboardingCell", forIndexPath: indexPath)
            let cellConfig = onboardingConfigs[indexPath.row]
            cell.backgroundColor = cellConfig.color
            if let onboardingCell = cell as? OnboardingCollectionViewCell {
                onboardingCell.mainLabel?.text = cellConfig.text.title
                onboardingCell.detailsLabel?.text = cellConfig.text.details
                onboardingCell.imageView?.image = UIImage(named: cellConfig.imageName)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SignInCell", forIndexPath: indexPath)
            if let signInCell = cell as? SignInCollectionViewCell {
                signInCell.backgroundColor = Colors.SignInColor
                signInCell.configure()
            }
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingConfigs.count + 1 //Sign In Cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let pageWidth = self.view.frame.size.width
        self.pageControl?.currentPage = Int(scrollView.contentOffset.x / pageWidth)
    }

}

class OnboardingCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var mainLabel : UILabel?
    @IBOutlet weak var detailsLabel : UILabel?
    @IBOutlet weak var imageView : UIImageView?
}

protocol SignInDelegate {
    func signInWithNumber(number: String)
    func invalidSignInAttempt()
}

//Sign in text view 
//formats phone number
//updated text with valid phone number or sms code
//submitted

class SignInCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var mainLabel:  UILabel?
    @IBOutlet weak var detailsLabel: UILabel?
    @IBOutlet weak var entryTextField: UITextField?
    @IBOutlet weak var orLabel: UILabel?
    @IBOutlet weak var submitButton: UIButton?
    @IBOutlet weak var anonymousLoginButton: UIButton?
    
    private var _entryMode : VolunteeringEntryMode = .None
    private var phoneNumber : String?
    
    var entryMode : VolunteeringEntryMode {
        get {
            return _entryMode
        }
        set {
            if newValue != _entryMode {
                _entryMode = newValue
                
                // clear out the text when changing entry modes
                self.entryTextField?.text = nil
                self.updateViewsForEntryMode(_entryMode)
            }
        }
    }
    
    var delegate : SignInDelegate?
    
    func configure() {
        self.validateSubmitButton()
        self.updateViewsForEntryMode(entryMode)
        self.entryTextField?.becomeFirstResponder()
    }
    
    //TODO: Localize
    private func updateViewsForEntryMode(entryMode: VolunteeringEntryMode) {
        switch entryMode {
        case .PhoneNumber, .None:
            self.entryMode = .PhoneNumber
            self.mainLabel?.text = "Add a phone number"
            self.detailsLabel?.text = "This only lets your driver reach you to arrange pickup. We never share your number with third parties."
            self.entryTextField?.placeholder = ""
            self.orLabel?.text = "or"
            self.submitButton?.setTitle("ADD A PHONE NUMBER", forState: .Normal)
            self.anonymousLoginButton?.setTitle("ADD A PHONE NUMBER LATER", forState: .Normal)
        case .ConfirmationCode:
            self.mainLabel?.text = "Add a phone number"
            self.detailsLabel?.text = "We sent a 4-digit SMS code to +1 314-814-0897. Enter it in below."
            self.entryTextField?.placeholder = "SMS Code"
            self.orLabel?.text = "or"
            self.submitButton?.setTitle("ENTER SMS CODE", forState: .Normal)
            self.anonymousLoginButton?.setTitle("ADD A PHONE NUMBER LATER", forState: .Normal)
        }
    }
    
    // MARK: User Actions
    
    @IBAction func loginCancelled(sender: AnyObject) {
        //performSegueWithIdentifier("loginViewDismissed", sender: nil)
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
    
    @IBAction func anonymousLoginButtonTapped(sender: AnyObject) {
        NSLog("Anonymous login button tapped")
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
                NSLog("Login successful")
                //self.performSegueWithIdentifier("successfulLogin", sender: nil)
            }
        })
    }
}
