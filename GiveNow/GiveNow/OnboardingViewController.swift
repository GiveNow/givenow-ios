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

class OnboardingViewController: BaseViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, LoginModalViewControllerDelegate {
    
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
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginCompleted:", name: "loginCompleted", object: nil)
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
            addLoginControllerToCell(cell)
            return cell
        }
    }
    
    func addLoginControllerToCell(cell: UICollectionViewCell) {
        let modalLoginView = LoginModalViewController(nibName: "LoginModalViewController", bundle: nil)
        modalLoginView.delegate = self
        modalLoginView.isModal = false
        addChildViewController(modalLoginView)
        
        let frame = CGRect(x: 20, y: 80, width: view.frame.width - 40, height: view.frame.height/2 - 80)
        modalLoginView.view.frame = frame
        cell.addSubview(modalLoginView.view)
        modalLoginView.didMoveToParentViewController(self)
    }
    
    func successfulLogin(controller: LoginModalViewController) {
        print("This happened")
        dismissOnboardingView()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onboardingConfigs.count + 1 //Sign In Cell
    }
    
    @IBAction func addAPhoneNumberLater(sender: AnyObject) {
        dismissOnboardingView()
    }
    
//    func loginCompleted(notification: NSNotification) {
//        dismissOnboardingView()
//    }
    
    func dismissOnboardingView() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
        
        if let parent = self.parentViewController as? InitialViewController {
            parent.displayMainViewController()
        }
        else {
            print("Not the parent")
        }
        
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
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
    
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var addPhoneLaterButton: UIButton!
    
    
}
