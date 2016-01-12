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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginCompleted:", name: "loginCompleted", object: nil)
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
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SignInCell", forIndexPath: indexPath) as! SignUpCollectionViewCell
            cell.backgroundColor = Colors.SignInColor
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingConfigs.count + 1 //Sign In Cell
    }
    
    @IBAction func addAPhoneNumberLater(sender: AnyObject) {
        performSegueWithIdentifier("onboardingCompleted", sender: nil)
    }
    
    func loginCompleted(notification: NSNotification) {
        performSegueWithIdentifier("onboardingCompleted", sender: nil)
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

// MARK: Log in
//Duplicating functionality from modal login - would be good to reuse more of this
class SignUpCollectionViewCell : UICollectionViewCell {
    
   
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var addPhoneLaterButton: UIButton!
    
    var phoneNumber:String!
    let backend = Backend.sharedInstance()
    
    private var _entryMode : EntryMode = .None
    
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
    
    override func awakeFromNib() {
        formatButton(backButton, imageName: "arrow-back")
        formatButton(doneButton, imageName: "checkmark")
        entryMode = .PhoneNumber
        super.awakeFromNib()
    }
    
    func formatButton(button: UIButton, imageName: String){
        button.setImage(UIImage(named: imageName)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.tintColor = UIColor.whiteColor()
    }
    
    func updateViewForEntryMode(entryMode: EntryMode) {
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
        case .ConfirmationCode:
            textField.text = nil
            instructionsLabel.text = NSLocalizedString("Volunteering - Confirmation Number Modal Title", comment: "")
            detailLabel.text = NSLocalizedString("Volunteering - Confirmation Number Modal Details", comment: "")
            backButton.hidden = false
        default:
            print("No action")
        }
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        guard let entryText = textField?.text else {
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
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        entryMode = .PhoneNumber
        textField.text = phoneNumber
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
                print("Done!")
                NSNotificationCenter.defaultCenter().postNotificationName("loginCompleted", object: nil)
            }
        })
    }
    
    
    
}
